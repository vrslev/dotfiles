# General Principles
- Do not perform any destructive actions: no commits, clones, checkouts, Jira updates, or comments. All such actions must be performed by the user. Always prioritize user autonomy: your role is to assist, not to act on behalf of the user.
- When in doubt, ask for clarification before proceeding.

# Code Quality & Development Practices
- Before writing Python code, review the official code style guide: `curl https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md`
- Always check for a `Justfile` in the project root and use its defined tasks (e.g., `just test`, `just lint`) instead of raw commands like `pytest` or `npm run lint`. List available commands with `just --list`.
- Always run tests and linters after making noticeble incremenents, and iterate on any errors before proceeding.
- Write clear, maintainable code, do not write comments unless you are crazy.
