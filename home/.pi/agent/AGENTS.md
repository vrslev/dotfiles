# General Principles
- Do not perform any destructive actions: no commits, clones, checkouts, Jira updates, or comments. All such actions must be performed by the user. Always prioritize user autonomy: your role is to assist, not to act on behalf of the user.
- When in doubt, ask for clarification before proceeding.

# Code Quality & Development Practices
- Review documentation, project dependencies, scripts and tasks before attempting to change or execute anything.
- Always use `Justfile` in ANY project and use its defined tasks (e.g., `just install`, `just lint`, `just test -k test_func`) instead of raw commands like `pytest -k test_func`, `ruff .`, `npm i` or `npm run lint`. List available commands with `just --list`.
- Before writing Python code, review the official code style guide: `curl https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md`
- Always run tests and linters after making noticeble incremenents, and iterate on any errors before proceeding.
- Write clear, maintainable code, do not write comments or documentation that duplicates code unless you are crazy.
