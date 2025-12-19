# General Principles
- Reading content (remote or local) is perfectly fine. But do not perform any **destructive** side effects: like commit, clones, checkouts, status updates, or comments. They must be performed by the user.

# Code Quality & Development Practices
- Always use `Justfile` in ANY project and use its defined tasks (e.g., `just install`, `just lint`, `just test -k test_func`) instead of raw commands like `pytest -k test_func`, `ruff .`, `npm i` or `npm run lint`. List available commands with `just --list`.
- Ensure complete type coverage and use explicit, meaningful variable names. Apply immutability principles where possible.
- Always run tests and linters after making noticeable increments, and iterate on any errors before proceeding.
- Do not write documentation that duplicates code unless you are crazy. Do not write comments at all. Do not write unnecessary examples.
