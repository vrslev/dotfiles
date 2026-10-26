import json
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / 'bin/utils/codex-state-backup'
BACKUP = runpy.run_path(str(SCRIPT))
PRIVATE_KEY_HEADER = '-' * 5 + 'BEGIN PRIVATE KEY' + '-' * 5


class BackupTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.home = self.root / 'codex'
        self.repository = self.root / 'backup'
        self.config = {'repository': str(self.repository), 'codex_home': str(self.home),
                       'push_enabled': False}
        for name in ('memories', 'memories_v2', 'automations/task'):
            (self.home / name).mkdir(parents=True)
        (self.home / 'memories/MEMORY.md').write_text('Useful context\n')
        (self.home / 'automations/task/automation.toml').write_text(
            'id="task"\nname="Task"\nprompt="Do the task"\nstatus="ACTIVE"\n'
            'rrule="FREQ=DAILY"\ntarget_thread_id="old-chat"\n')
        state = {'local-projects': {'p': {'id': 'p', 'name': 'Project', 'rootPaths': ['/code'],
                                          'unexpected': 'must not export'}},
                 'pinned-thread-ids': ['old-chat'], 'device-token': 'private',
                 'electron-persisted-atom-state': {'prompt-history': ['private'],
                                                  'markdownCodeBlockWordWrap': True}}
        (self.home / '.codex-global-state.json').write_text(json.dumps(state))
        self.repository.mkdir()
        self.git('init', '--quiet', '--initial-branch=main')
        self.git('config', 'user.name', 'Backup Test')
        self.git('config', 'user.email', 'backup@example.invalid')

    def git(self, *args: str) -> str:
        return subprocess.check_output(['git', '-C', str(self.repository), *args], text=True).strip()

    def test_round_trip_filters_and_no_op(self) -> None:
        (self.home / 'memories/.git').mkdir()
        (self.home / 'memories/.git/private.md').write_text('ignored')
        (self.home / 'memories/cache.sqlite').write_text('ignored')
        (self.home / 'automations/task/memory.md').write_text('ignored')
        first = BACKUP['snapshot'](self.config)
        files = BACKUP['verify'](self.repository / 'snapshot')
        self.assertEqual(set(files), {'memories/MEMORY.md', 'automations/task/automation.toml',
                                      'global-state.json'})
        state = json.loads(files['global-state.json'])
        self.assertNotIn('device-token', state)
        self.assertNotIn('unexpected', state['local-projects']['p'])
        self.assertNotIn('prompt-history', state['electron-persisted-atom-state'])
        second = BACKUP['snapshot'](self.config)
        self.assertFalse(second['changed'])
        self.assertEqual(first['commit'], second['commit'])
        self.assertNotIn('[remote "', (self.repository / '.git/config').read_text())

    def test_removed_source_is_recorded_but_previous_commit_survives(self) -> None:
        first = BACKUP['snapshot'](self.config)
        (self.home / 'memories/MEMORY.md').unlink()
        second = BACKUP['snapshot'](self.config)
        self.assertNotEqual(first['commit'], second['commit'])
        self.assertNotIn('memories/MEMORY.md', BACKUP['verify'](self.repository / 'snapshot'))
        self.assertEqual(self.git('show', first['commit'] + ':snapshot/memories/MEMORY.md'),
                         'Useful context')

    def test_secret_rejection_preserves_snapshot(self) -> None:
        first = BACKUP['snapshot'](self.config)
        (self.home / 'memories/MEMORY.md').write_text(PRIVATE_KEY_HEADER)
        with self.assertRaisesRegex(ValueError, 'Possible credential'):
            BACKUP['snapshot'](self.config)
        self.assertEqual(self.git('rev-parse', 'HEAD'), first['commit'])
        self.assertEqual(BACKUP['verify'](self.repository / 'snapshot')['memories/MEMORY.md'],
                         b'Useful context\n')

    def test_filtered_source_secrets_do_not_block_safe_export(self) -> None:
        path = self.home / '.codex-global-state.json'
        state = json.loads(path.read_text())
        state['excluded-secret'] = PRIVATE_KEY_HEADER
        path.write_text(json.dumps(state))
        files = BACKUP['collect'](self.home)
        self.assertNotIn(b'PRIVATE KEY', files['global-state.json'])

    def test_symlink_rejected(self) -> None:
        (self.home / 'memories/linked.md').symlink_to(self.home / 'memories/MEMORY.md')
        with self.assertRaisesRegex(ValueError, 'Symlink'):
            BACKUP['snapshot'](self.config)

    def test_tampering_and_traversal_rejected(self) -> None:
        BACKUP['snapshot'](self.config)
        snapshot = self.repository / 'snapshot'
        (snapshot / 'memories/MEMORY.md').write_text('changed')
        with self.assertRaisesRegex(ValueError, 'checksum'):
            BACKUP['verify'](snapshot)
        (snapshot / 'manifest.json').write_text(json.dumps(
            {'version': 1, 'files': {'../outside.md': {'sha256': '', 'bytes': 0}}}))
        with self.assertRaisesRegex(ValueError, 'Unsafe'):
            BACKUP['verify'](snapshot)

    def test_local_changes_are_preserved(self) -> None:
        BACKUP['snapshot'](self.config)
        readme = self.repository / 'README.md'
        readme.write_text('Human edit\n')
        with self.assertRaisesRegex(ValueError, 'local changes'):
            BACKUP['snapshot'](self.config)
        self.assertEqual(readme.read_text(), 'Human edit\n')

    def test_restore_cli_only_writes_destination(self) -> None:
        BACKUP['snapshot'](self.config)
        config = self.root / 'config.json'
        config.write_text(json.dumps(self.config))
        source = self.home / 'memories/MEMORY.md'
        source.write_text('Live changes\n')
        destination = self.root / 'restored'
        subprocess.run(['python3', str(SCRIPT),
                        '--config', str(config), 'restore', '--destination', str(destination)],
                       check=True, capture_output=True)
        self.assertEqual((destination / 'memories/MEMORY.md').read_text(), 'Useful context\n')
        self.assertEqual(source.read_text(), 'Live changes\n')

    def test_push_disabled_even_with_an_unreachable_origin(self) -> None:
        self.git('remote', 'add', 'origin', str(self.root / 'missing-remote'))
        config = self.root / 'config.json'
        config.write_text(json.dumps(self.config))
        subprocess.run(['python3', str(SCRIPT),
                        '--config', str(config), 'snapshot'],
                       check=True, capture_output=True)
        status = json.loads((self.root / 'status.json').read_text())
        self.assertTrue(status['ok'])
        self.assertFalse(status['push_enabled'])
        self.assertNotIn('last_successful_push', status)


    def test_push_rejects_an_unapproved_destination(self) -> None:
        self.git('remote', 'add', 'origin', str(self.root / 'different-remote'))
        self.config.update(push_enabled=True,
                           expected_remote=str(self.root / 'approved-remote'))
        config = self.root / 'config.json'
        config.write_text(json.dumps(self.config))
        result = subprocess.run(['python3', str(SCRIPT), '--config', str(config), 'snapshot'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn('approved destination', result.stderr)
        status = json.loads((self.root / 'status.json').read_text())
        self.assertFalse(status['ok'])
        self.assertNotIn('last_successful_push', status)


if __name__ == '__main__':
    unittest.main()
