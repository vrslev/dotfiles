---
description: Comply with Python code style
---

1. Read code style `curl -s https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md`, look for rules that are not automated.
2. Check changes that you've made or those that were there in git work tree. $@
3. Generate suggestions for changes according to code style. Before modifying code, ask me if your plan is ok.
4. Modify the code.

## Rules

- I don't want to fix code you've written, so your goal is make it as close as possible to our standards. Otherwise I will have to do it or colleagues will bring this up on review.
- Do not run linters or tests, just check code compliance and fix the issues after checking in with me.
- Do not update code that is not in work tree or you already changed after feature request! You'll be stopped if you do. For example, if settings.py is in git status, but you change ioc.py, you're stopped. Only update what you really changed, I mean lines, not files.
- Be sensible, but don't hesitate to making not commonly accepted suggestions. Though, if project generally does things the way that doesn't comply with code style, it probably is ok. Consistency is the best.
- Be specific.

## Additional code style

- Remove comments and docstrings almost always.
- Keep typing.Final for scalars
