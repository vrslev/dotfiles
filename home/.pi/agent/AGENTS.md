# Common Rules
- Do not do anything destructive: do not commit, clone, checkout, do not update Jira issues, leave comments. User will do it themselves! This applies both to coding and non-coding stuff.

# QA
- Before writing Python, read through the code style: `curl https://raw.githubusercontent.com/community-of-python/pylines/refs/heads/main/code-style.md` so that user doesn't have to rewrite your code too much to comply to code style.
- Often enough, project will have `./Justfile`. In that case, you have to use commands from that file (like `just test` or `just lint`) instead of raw commands like `pytest` or `npm run lint`. Check available commands with `just --list`.
- Run tests and linters and iterate on errors after you've done some noticeble increment.
