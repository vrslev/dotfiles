---
name: web-browser
description: Drive Chrome from the shell to browse, click, fill forms, run JS, and screenshot. Use for dynamic sites, web UIs, or content curl cannot reach.
---

# Web Browser Skill

Uses [agent-browser](https://github.com/vercel-labs/agent-browser) — Rust CLI over CDP. Daemon persists Chrome between calls.

## Typical flow

`--session <session-slug>` isolates from the user's browser; pick a task-specific kebab-case slug (e.g. `grafana-improvement`, `jira-triage`). Use `batch` to run multiple steps in one invocation; fall back to single calls only when you need to inspect output between steps (snapshot → reason → click).

```bash
agent-browser batch --session <session-slug> \
  "open https://example.com" \
  "snapshot -i" \
  "screenshot out.png" \
  "close"
```

Refs `@eN` come from the latest `snapshot`. Traditional CSS selectors also work (`click "#submit"`).

Headless by default. Add `--headed` to show the window. It only takes effect when the daemon starts — if you see `⚠ --headed ignored: daemon already running`, run `agent-browser --session <session-slug> close` and retry.

## Reading the page

- `snapshot -i` — compact accessibility tree, best for agent reasoning
- `get text @e1` / `get html @e1` / `get value @e1` / `get title` / `get url`
- `eval '<js>'` (`--stdin` for piped JS)

## Finding elements semantically

```
find role button click --name "Submit"
find text "Sign In" click
find label "Email" fill "me@example.com"
```

## Checks

`is visible|enabled|checked <sel>` — exit code reflects state.

## Everything else

`agent-browser --help` and `agent-browser <cmd> --help` for the full list (waits, tabs, uploads, pdf, recording, sessions). Prefer one-shot commands composed with shell over large eval blobs.
