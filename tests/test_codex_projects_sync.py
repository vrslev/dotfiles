# pyright: strict
import contextlib
import fcntl
import io
import json
import os
from pathlib import Path
import runpy
import sys
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / 'bin/utils/codex-projects-sync'
SYNC = runpy.run_path(str(SCRIPT))


class ProjectSyncTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.cache = self.root / 'cache'
        self.cache.mkdir()
        self.state = self.root / 'state.json'
        self.state.write_text(json.dumps({'local-projects': {}, 'project-order': []}))
        self.config = self.root / 'config.json'
        self.config.write_text(json.dumps({'state': str(self.state), 'cache': str(self.cache),
                                          'projects': [{'name': 'Project', 'roots': [str(self.root)]}]}))

    def run_main(self, *args: str) -> None:
        with patch.object(sys, 'argv', [str(SCRIPT), '--config', str(self.config), *args]), contextlib.redirect_stdout(io.StringIO()):
            SYNC['main']()

    def test_optional_report_failure_preserves_canonical_status(self) -> None:
        blocked = self.root / 'blocked'
        blocked.write_text('file, not directory')
        error = io.StringIO()
        with contextlib.redirect_stderr(error):
            SYNC['status']({'report': str(blocked / 'report.json')}, self.cache, {'status': 'applied'})
        self.assertEqual(json.loads((self.cache / 'status.json').read_text()), {'status': 'applied'})
        self.assertIn('Optional project report', error.getvalue())

    def test_duplicate_request_preserves_lock_owners_status(self) -> None:
        value = {'status': 'waiting-for-app-exit', 'workerPid': 123}
        SYNC['write_json'](self.cache / 'status.json', value)
        with (self.cache / 'pending.lock').open('w') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with patch.dict(SYNC['main'].__globals__, running=lambda: True), patch('subprocess.Popen') as spawn:
                self.run_main('--apply')
                spawn.assert_called_once()
            self.run_main('--wait')
        self.assertEqual(json.loads((self.cache / 'status.json').read_text()), value)

    def test_waiting_worker_publishes_its_own_pid(self) -> None:
        with patch.dict(SYNC['main'].__globals__, running=lambda: True), patch('time.sleep', side_effect=InterruptedError):
            with self.assertRaises(InterruptedError):
                self.run_main('--wait')
        value = json.loads((self.cache / 'status.json').read_text())
        self.assertEqual(value['status'], 'waiting-for-app-exit')
        self.assertEqual(value['workerPid'], os.getpid())
        self.assertEqual(value['projects'], [{'name': 'Project', 'roots': [str(self.root)]}])

    def test_no_op_apply_completes_waiting_status(self) -> None:
        state = {'local-projects': {'p': {'id': 'p', 'name': 'Project', 'rootPaths': [str(self.root)],
                                          'createdAt': 1, 'updatedAt': 1}}, 'project-order': ['p']}
        self.state.write_text(json.dumps(state))
        SYNC['write_json'](self.cache / 'status.json', {'status': 'waiting-for-app-exit'})
        self.run_main('--apply')
        value = json.loads((self.cache / 'status.json').read_text())
        self.assertEqual(value['status'], 'applied')
        self.assertFalse(value['changed'])
        self.assertEqual(json.loads(self.state.read_text()), state)

    def test_failed_atomic_replace_removes_temporary_file(self) -> None:
        with patch('os.replace', side_effect=PermissionError):
            with self.assertRaises(PermissionError):
                SYNC['write_json'](self.cache / 'status.json', {'status': 'applied'})
        self.assertEqual(list(self.cache.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
