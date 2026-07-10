---
name: subagent
description: |
  Spawn sub-agents with `pi -p` for parallel or delegated work. Read before running `pi -p`. Use when a task can be split into independent subtasks, needs a fresh/isolated context, benefits from an independent second opinion, or asks for parallel review/search/audit across files, repos, logs, or alternatives.
---

# Subagent

Spawn focused pi sub-agents via `pi -p` (non-interactive mode). Each gets its own context and tools, runs to completion, returns output to stdout.

```bash
pi -p "Summarize the README.md in this repo"
pi -p @src/main.py "Find unused imports"
cat file.py | pi -p "Review this code for bugs"
```

Parallel execution:

```bash
pi -p "Analyze src/auth.py for security issues" > /tmp/auth.md &
pi -p "Analyze src/api.py for security issues" > /tmp/api.md &
wait
```

Use `--no-tools` for pure reasoning, `--tools read` for read-only analysis. Keep prompts focused on a single task.

## Timeouts

Set the wrapper/tool timeout higher than you think the subagent needs, especially for parallel runs or repo-wide reviews. Subagents often spend extra time on tool calls and synthesis; timing them out wastes the work already done. Prefer 2-3x your estimate over the smallest plausible timeout.

## Good delegation prompts

Include scope, constraints, output format, and whether edits are allowed:

```bash
pi -p --tools read "Review src/auth.py for security issues. Do not edit. Return only findings with file/line references."
pi -p "Find likely causes of the failing checkout test. Make no changes; summarize evidence and next checks."
```

For parallel runs, write each result to a temp file, `wait`, then read and synthesize. Do not spawn subagents for tiny tasks where direct inspection is faster.
