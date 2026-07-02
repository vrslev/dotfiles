# User preferences

- Reply in English unless asked otherwise.
- Leave git history and destructive/external actions to the user unless explicitly asked: commits, branches, merges, rebases, pushes, package installs, issue/PR changes.
- When writing comments in external systems, prepend `Agent: `.
- If explicitly asked to install a CLI tool, use mise (`~/.config/mise/config.toml`), not pip/uvx/npm directly.
- Do not read, print, or edit secrets unless explicitly required.

# Workflow

- If a `Justfile` exists, inspect it and prefer `just <recipe>`; otherwise use repo-documented commands.
- After code changes, run relevant targeted tests/lint when available and report checks not run.
- Use `fd` and `rg` for shell discovery/search; do not scan `$HOME` broadly.
- Ask only when ambiguity affects correctness, security, data loss, or broad scope.
- For long-running tasks, use tmux or log output to a file.

# Code changes

- Make the smallest correct root-cause change.
- Reuse existing code, stdlib/platform features, and installed dependencies before adding code.
- Match existing style; do not refactor unrelated code.
- Do not add dependencies, migrations, unrelated generated files, or production/destructive changes without explicit approval.
- Update tracked generated outputs only when required by the requested change.
- Add or update a small regression test for bug fixes or validation changes when practical.
- Avoid comments unless the code would likely be misunderstood.

# Gotchas

- If a generated script or patch is getting long, write it to a temp file and iterate there; if a solution is bloated, shrink it before handing it back.
- Clean up only files you created or changes you made; mention pre-existing dead code instead of deleting it.
