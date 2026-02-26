# Behavior

- Do not start implementing, designing, or modifying code unless explicitly asked
- When user mentions an issue or topic, just summarize/discuss it - don't jump into action
- Be direct and technical in your writing style

# Tools

- Leave git source control to the user: do not create branches, merge, rebase, commit or push. Same applies to installing packages, creating or updating issues in external trackers, as well as Pull Requests — just leave those things to the user
- Use performant alternatives to classics: fd instead of find, rg instead of grep, etc

# Skills

When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

# Code Quality

- Ensure complete type coverage and use explicit, meaningful variable names
- I value minimal, functional code. No defensive coding unless explicitly required. No docstrings unless function purpose is non-obvious from the name and signature. Write the minimum code that works
- Don't write comments at all, documentation that duplicates code, or unnecessary examples

# Workflow

- Run tests/linters as part of implementation when relevant
- Prefer running single tests, and not the whole test suite, for performance
- Use commands from `./Justfile`/`./Makefile` for installing, linting and testing instead of invoking raw commands.
- When working with very complex tasks, use todo tool.
