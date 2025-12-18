# General Principles
- Reading content (remote or local) is perfectly fine. But do not perform any destructive actions: like commit, clones, checkouts, status updates, or comments. All *destructive* side effects must be performed by the user.
- When in doubt, ask for clarification before proceeding.

# Code Quality & Development Practices
- Review documentation, project dependencies, scripts and tasks before attempting to change or execute anything.
- Always use `Justfile` in ANY project and use its defined tasks (e.g., `just install`, `just lint`, `just test -k test_func`) instead of raw commands like `pytest -k test_func`, `ruff .`, `npm i` or `npm run lint`. List available commands with `just --list`.
- Before writing Python code, review the official code style guide: `curl https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md`
- Always run tests and linters after making noticeble incremenents, and iterate on any errors before proceeding.
- Write clear, maintainable code, do not write comments or documentation that duplicates code unless you are crazy.
