# Codex project reconciliation

Keep machine-specific project roots in `~/.config/codex-projects/config.json`:

```json
{
  "projects": [
    {"name": "product", "roots": ["~/code/acme/product"]},
    {"name": "tool", "roots": ["~/code/acme/tool"]}
  ],
  "discover": [
    {"under": "~/code/acme/libraries", "pattern": "*/.git", "prefix": "lib-"}
  ]
}
```

Product folders include future child repositories as they are cloned. Discovery
rules create separate projects for matching local repositories. They do not
discover or clone remote repositories. Keep independently maintained packages
and shared tools as separate projects, even when a product folder includes them.

`codex-projects-sync` previews the catalog. `codex-projects-sync --apply` applies
it when ChatGPT/Codex is closed, or queues one reconciliation for app exit. A
queued run writes its result to `~/.cache/codex-projects/status.json`; errors go
to `pending.log` in that directory. Wait until the status says `applied` before
reopening the app normally. No terminal launcher is needed for daily app use.

The command updates the desktop catalog and its SQLite project records together,
retains unrelated projects, repairs configured paths by project name, and moves
threads from replaced repository projects into the containing product project.
Explicitly projectless threads stay projectless. It preserves thread contents,
archive state, checkouts, branches, and worktrees. Backups are saved under
`~/.cache/codex-projects/backups/` before changes. The database schema is checked
before writes; this local compatibility integration may need updating when the
app changes its persistence format.

`sync-repos` invokes reconciliation when the configuration file exists. Its
configured remote groups live in `~/.config/sync-repos/groups`; discovery clones
active repositories and leaves existing archived checkouts in place. There is
no background remote polling: new repositories appear on the next `sync-repos`
run. A new product or repository outside configured groups still needs an
explicit configuration entry.

A parent-folder project is not a Git repository. Branches, commits, diffs, and
worktrees remain scoped to each child repository; it does not create a shared
branch or a monorepo.
