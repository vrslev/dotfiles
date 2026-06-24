# User preferences

- Leave git source control and destructive actions to the user. Do not create commits, branches, merge, rebase, or push; do not install packages, create/update issues/PRs. Though if user asked explicitly, do it.
- When leaving comments in external systems, prepend `Agent: `.
- Reply in English, unless user asks otherwise.

# Tools

- Use performant alternatives over classic CLIs: find → fd, rg → grep, etc. Do not use find and grep.
- Use quiet mode when tool has it.
- Use commands from `./Justfile` for development flow.
- Use tmux for background tasks and long tasks.
- When tasks take more than 3 minutes, redirect its output to the file and read it—instead of running the same command multiple time and grepping output directly.
- Don't compose and execute generated scripts inline when they exceed 50 lines. Write the script to a tmp file, execute it, then fix failures by editing that file instead of rewriting it.
- Don't `cd` into the current working directory. Run commands directly; only `cd` when targeting a different dir.

# Code Quality

These guidelines bias toward caution over speed. For trivial tasks, use judgment.

- Don't assume. Don't hide confusion. Surface tradeoffs. If multiple interpretations exist, present them—don't pick silently. If unclear, stop and ask. (Asking a clarifying question is not hedging; the no-hedging rule below applies to wishy-washy phrasing in answers, not to genuine uncertainty.)
- If a simpler approach exists, say so. Push back when warranted.
- Touch only what you must. Match existing style. Don't refactor what isn't broken. Every changed line should trace to the request.
- Clean up only your own mess: remove orphans your changes created; mention pre-existing dead code, don't delete it.
- Define success criteria. Loop until verified. For multi-step tasks, state a brief plan with a verify check per step.
- Minimum code that solves the problem. Nothing speculative. No abstractions for single-use code, no unrequested flexibility, no error handling for impossible cases. If you wrote 200 lines and it could be 50, rewrite it.
- Ensure complete type coverage. Use explicit, meaningful variable names. Don't write comments at all, documentation that duplicates code, or unnecessary examples

# Tests

- Bug fix → write a failing regression test, then make it pass.
- Validation change → test invalid inputs, then make them pass.
- Refactor → ensure tests pass before and after.
- Run tests and linters as part of implementation.
- Open PR/MR: run/watch CI in parallel with local tests.
- Prefer targeted tests; run full suite for final verification when useful.
- Avoid real sleeps in tests unless waiting for real external deps.
- Parametrize tests that differ only by input, expected output, or error.
- Cover new branches and edge cases; aim for 100% coverage on new code.

## Memory

- Install new CLI tools via mise (add to `~/.config/mise/config.toml` as `pipx:name` or `npm:name`), not pip/uvx/npm directly.
