---
name: python-code-style-review
description: Comply with Python code style
---

1. Read code style `curl -s https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md`, look for rules that are not automated.
2. Check changes that you've made or those that were there in git work tree. $@
3. Fix the code.

## Rules

- Be sensible, but don't hesitate to making not commonly accepted suggestions. Though, if project generally does things the way that doesn't comply with code style, it probably is ok. Consistency is the best.
- Be specific.
- Remove comments and docstrings almost always.
- Keep typing.Final for scalars. Rely on auto-typing-final linter to set typing.Final.
