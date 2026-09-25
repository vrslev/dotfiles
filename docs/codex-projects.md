# Codex project reconciliation

Keep machine-specific project roots in `~/.config/codex-projects/config.json`:

```json
{
  "projects": [
    {"name": "product", "roots": [], "repositoriesUnder": ["~/code/acme/product"]},
    {"name": "community", "roots": [], "repositoriesUnder": ["~/code/public/community", "~/code/private/community"]},
    {"name": "personal-tool", "roots": ["~/code/personal/tool"]}
  ],
  "discover": []
}
```

`repositoriesUnder` finds Git repositories below each parent and registers their
checkout paths as roots of the same project. It excludes linked worktrees, whose
`.git` marker is a file, so temporary worktrees do not fill the project root
list. Each new task should use the relevant repository root to enable Review.
The next reconciliation picks up newly cloned repositories. Group related
services, packages, and tools together; reserve standalone projects for
repositories outside those groups. Optional `discover` rules create separate
projects and do not discover or clone remote repositories.

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

Review, branches, commits, diffs, and worktrees remain scoped to each repository
root. Changing a project's roots does not change the working directory stored
on existing tasks. Tasks rooted at a former non-Git parent folder still need a
repository-specific task or review path.
