# Tools
- Leave git source control to the user: do not create branches, merge, rebase, commit or push.
- Same applies to installing packages, creating or updating issues in external trackers, as well as Pull Requests. Just leave those things to the user.
- Use fd instead of find, rg instead of grep.
- If the user names a skill OR the task clearly matches a skill's description, you must use that skill for that turn. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.

# Workflow
- Given a task, do just what is asked, not more.
- Use `Justfile` in any project and use its defined tasks (e.g., `just install`, `just lint`, `just test test_file.py`) instead of raw commands like `pytest test_file.py`, `ruff .`, `npm i` or `npm run lint`. List available commands with `just --list`.
- Use `run-silent <cmd>` for running tests and lints, when output is irrelevant stuff to avoid polluting context: `run-silent just test`.
- Run tests and linters after making noticeable increments, and iterate on any errors before proceeding.
- Prefer running single tests, and not the whole test suite, for performance

# Code Quality
- Check other files before writing code to get the code style
- Ensure complete type coverage and use explicit, meaningful variable names
- Don't write comments at all, documentation that duplicates code, or unnecessary examples
- I value minimal, functional code. No defensive coding unless explicitly required. No docstrings unless function purpose is non-obvious from the name and signature. Write the minimum code that works
