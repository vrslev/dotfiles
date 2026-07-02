---
name: gitlab
description: Interact with GitLab using `glab` CLI.
---

# GitLab Skill

Use the glab CLI to interact with GitLab.

```bash
# Get help
glab --help
glab <command> --help

# API access
glab api <endpoint> | jq .

# Common commands
glab mr list
glab mr view <id>
glab mr diff <id>
glab issue list
glab issue view <id>
glab ci list
glab repo clone <repo>
```
