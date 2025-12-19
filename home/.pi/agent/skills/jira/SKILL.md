---
name: jira
description: Access to Atlassian Jira with `jira` CLI.
---

# Jira

Interact with Jira issues, projects, sprints, and boards using `jira` CLI.

## Search & View

```bash
jira issue list --plain --columns key,summary,status,assignee
jira issue list --jql 'project = PROJ AND status = "In Progress"' --plain
jira issue view PROJ-123 --plain --comments 5
```

## Projects & Sprints

```bash
jira project list --plain --columns key,name,type
jira board list --plain --columns id,name,type
jira sprint list --plain --columns id,name,state,start,end
```

## Output Flags

- `--plain` — TSV output for clean streaming
- `--raw` — JSON output for structured data
- `--columns key,summary,status` — select specific columns

## Learn more using help

```bash
jira --help
jira issue --help
```

## When to Use

- Searching and viewing Jira issues
- Creating or updating issues, comments, worklogs
- Listing projects, boards, sprints
