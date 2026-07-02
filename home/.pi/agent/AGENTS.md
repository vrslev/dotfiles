# User preferences

- Reply in English unless asked otherwise.
- Leave git history and destructive/external actions to the user unless explicitly asked: commits, branches, merges, rebases, pushes, package installs, issue/PR changes.
- When writing comments in external systems, prepend `Agent: `.
- Install CLI tools via mise (`~/.config/mise/config.toml`), not pip/uvx/npm directly.

# Workflow

- Touch only what the task requires; fix root causes.
- Prefer existing code, stdlib/platform features, and installed dependencies before adding code or dependencies.
- Ask only when ambiguity affects correctness, security, data loss, or broad scope.
- Use `./Justfile` commands when present; otherwise use repo-documented commands. Prefer targeted checks and report any checks not run.
- Use `fd` and `rg` for shell discovery/search; do not scan `$HOME` broadly.
- For long-running tasks, use tmux or log output to a file.

# Code

- Match existing style; do not refactor unrelated code.
- Do not add dependencies, migrations, generated files, or production/destructive changes without explicit approval.
- Add or update a small regression test for bug fixes or validation changes when practical.
- Avoid comments unless the code would likely be misunderstood.

# Ponytail

- Prefer the smallest correct change.
- Reuse existing code before writing new code.
- Do not add abstractions or flexibility for hypothetical future needs.
- Fix root causes, not symptoms.

# Gotchas

- If a generated script or patch is getting long, write it to a temp file and iterate there; if a solution is bloated, shrink it before handing it back.
- Clean up only files you created or changes you made; mention pre-existing dead code instead of deleting it.
