# Tools

- Use performant alternatives over classic CLIs: find → fd, rg → grep, etc.
- Use tmux for background tasks and long tasks.
- Use commands from `./Justfile` for development flow.

# Code Quality

- Don't assume. Don't hide confusion. Surface tradeoffs.
- Touch only what you must. Clean up only your own mess.
- Define success criteria. Loop until verified.
- Minimum code that solves the problem. Nothing speculative.
- Ensure complete type coverage. Use explicit, meaningful variable names. Don't write comments at all, documentation that duplicates code, or unnecessary examples
- Run tests and linters as part of implementation.
- Prefer running single tests, and not the whole test suite (though it's OK to run the whole suite for verification before you're done)

# User preferences

- Leave git source control and destructive actions to the user. Do not create commits, branches, merge, rebase, or push; do not instal packages, create÷update issues/PRs. Though if user asked explicitly, do it.
