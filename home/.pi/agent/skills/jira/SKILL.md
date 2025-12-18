---
name: jira
description: Operate Atlassian Jira through the official jira CLI; trigger this skill to list, inspect, create, update, triage, or report on Jira work using deterministic shell commands.
version: 0.1.0
---

# Jira Issue Management

**Use this skill whenever Jira work is requested.**

## Setup

- `jira` CLI already in PATH.
- Token already set, so don't worry about it.
- Use upstream flags like `--project`, `--board`, etc., for context as needed; no extra configuration lives in the skill.

## Command Pattern

```bash
jira <command> <subcommand> [arguments] [flags]
```

Primary commands: `issue`, `project`, `board`, `sprint`, `epic`, `release`, `open`, `me`, `serverinfo`.

Keep outputs deterministic:

- Add `--plain` plus `--columns ...` for TSV tables that stream cleanly.
- Use `--raw` (alias for JSON) when structured data is required.
- Provide explicit ranges via `--paginate start:limit` to cap interactive views.

## Core Workflows

- **Projects** – enumerate available projects
  ```bash
  jira project list --plain --columns key,name,type
  ```

- **Issues**
  - Search / filter:
    ```bash
    jira issue list --status Done --assignee "$(jira me)" --plain --columns key,summary,status,assignee
    jira issue search 'project = PROJ AND status = "In Progress"' --plain --columns key,summary,status
    jira issue list --raw --jql 'label = backend' --paginate 0:50
    ```
  - View details: `jira issue view PROJ-123 --plain --comments 5`
  - Create:
    ```bash
    jira issue create \
      --type Bug \
      --summary "API returns 500" \
      --description-file docs/bug.md \
      --priority High \
      --assignee "$(jira me)" \
      --label backend --label urgent
    ```
  - Update:
    ```bash
    jira issue edit PROJ-123 --summary "Refine API contract" --priority Medium
    jira issue move PROJ-123 "In Review" --comment "Ready for QA"
    jira issue assign PROJ-123 user@example.com
    ```
  - Comment / worklog:
    ```bash
    jira issue comment add PROJ-123 "Investigating..." --no-input
    jira issue worklog add PROJ-123 "1h 30m" --comment "Debugging"
    ```
  - Linking: `jira issue link PROJ-1 PROJ-2 "Blocks"` (remove with `jira issue unlink ...`).

- **Epics**
  - Create: `jira epic create --name "Platform Stability" --summary "Q3 initiative"`
  - List: `jira epic list --plain --columns key,summary,status`
  - Attach issues: `jira epic add EPIC-1 PROJ-123 PROJ-456`

- **Boards & Sprints**
  - Boards: `jira board list --plain --columns id,name,type`
  - Sprint overview: `jira sprint list --plain --columns id,name,state,start,end`
  - Sprint issues: `jira sprint list <SPRINT_ID> --plain --columns key,summary,status,assignee`
  - Move issues: `jira sprint add <SPRINT_ID> PROJ-123 PROJ-456`
  - Close sprint: `jira sprint close <SPRINT_ID>`

- **Releases (Versions)** – `jira release list --plain --columns name,start,end,state`

- **Open in browser** – `jira open PROJ-123 --no-browser` (omit flag to launch UI).

- **User / Instance context** – `jira me`, `jira serverinfo`, `jira version`.

## Output Strategies

- Issues default to `key,summary,status,assignee`; sprints to `id,name,state,start,end`. Override with `--columns`.
- `--raw` returns JSON for downstream processing (`jq`, scripting).
- Combine commands with standard Unix tooling:
  ```bash
  jira issue list --plain --columns key,status,assignee | rg "In Progress"
  jira issue view PROJ-123 --plain --comments 10 | tee PROJ-123.txt
  ```
