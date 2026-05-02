---
name: subagent
description: |
  Spawn a sub-agent using `pi -p` for parallel or delegated work. Use when:
  - A task can be broken into independent subtasks run in parallel
  - A focused, isolated context is needed for a subtask
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
