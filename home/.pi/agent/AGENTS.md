# Behavior

- Do not start implementing, designing, or modifying code unless explicitly asked
- When user mentions an issue or topic, just summarize/discuss it - don't jump into action
- Be direct and technical in your writing style

# Tools

- Leave git source control to the user: do not create branches, merge, rebase, commit or push
- Same applies to installing packages, creating or updating issues in external trackers, as well as Pull Requests — just leave those things to the user
- Use fd instead of find, rg instead of grep

# Code Quality

- I value minimal, functional code. Write the minimum code that works
- No defensive coding unless explicitly required
- No comments, docstrings, documentation or examples unless function/module purpose is non-obvious from the name and signature (better to make it obvious!)
- Ensure complete type coverage and use explicit, meaningful variable names

# Workflow

- Run tests and linters after making noticeable increments, and iterate on any errors before proceeding.
- Prefer running single tests, and not the whole test suite, for performance
- Use commands from `./Justfile` for installing, linting and testing instead of invoking raw commands.
