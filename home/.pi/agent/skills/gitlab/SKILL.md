---
name: gitlab
description: Manage and view GitLab resources
---

# GitLab CLI (glab) Skill

This skill provides access to GitLab CLI (glab) commands.

## Description
The glab skill allows executing GitLab CLI commands for interacting with GitLab instances. It checks for the presence of the `glab` command-line tool and uses it to perform various GitLab operations.

## Requirements
- `glab` CLI tool must be installed and available in PATH

## Usage
```bash
# Get help
glab --help
glab <command> --help

# API access
glab api <endpoint> | jq .

# Common commands
glab mr list
glab issue list
glab repo clone <repo>
```

## Notes
- Authentication is handled by glab configuration if needed
- Visit https://gitlab.com/gitlab-org/cli for installation instructions
