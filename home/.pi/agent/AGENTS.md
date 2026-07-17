# User preferences

- Reply in English unless asked otherwise.
- Leave git history and destructive/external actions to the user unless explicitly asked: commits, branches, merges, rebases, pushes, package installs, issue/PR changes.
- When writing comments manually in external systems, prepend `Agent: `. Preserve messages rendered or posted by utilities from an applicable skill selected from the runtime skill catalog or an approved private registry exactly.
- If explicitly asked to install a CLI tool, use mise (`~/.config/mise/config.toml`), not pip/uvx/npm directly.
- Do not read, print, or edit secrets unless explicitly required.

# Autonomy

- Set autonomy from verification, reversibility, and blast radius—not task labels. Subject to the explicit boundaries in this file, act, verify, and iterate without asking for scoped, reversible local work.
- Treat material changes to shared operational state with meaningful blast radius as a two-turn boundary, even when initially requested. Expected, reversible, low-risk side effects within an explicitly requested workflow do not require another confirmation. When an applicable skill selected from the runtime skill catalog or an approved private registry defines confirmation gates, follow those gates within its scope; add another gate only if the target is ambiguous, the action exceeds that scope, or the risk is materially greater than the skill accounts for.
- In reviews, report only issues that could materially affect correctness, safety, scope, or verification.

# Workflow

- If a `Justfile` exists, inspect it and prefer `just <recipe>`; otherwise use repo-documented commands.
- After code changes, run relevant targeted tests/lint when available and report checks not run.
- Use `rg` for content search and `rg --files` for repo-scoped file discovery; use `find` for path/type/depth-specific discovery when needed; do not scan `$HOME` broadly.
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
