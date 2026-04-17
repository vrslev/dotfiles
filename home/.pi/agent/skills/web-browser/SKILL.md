---
name: web-browser
description: Drive Chrome from the shell to browse, click, fill forms, run JS, and screenshot. Use for dynamic sites, web UIs, or content curl cannot reach.
---

# Web Browser Skill

Uses [agent-browser](https://github.com/vercel-labs/agent-browser) — Rust CLI over CDP. Daemon persists Chrome between calls.

## Typical flow

```bash
agent-browser open https://example.com
agent-browser snapshot -i             # compact a11y tree with @eN refs
agent-browser click @e5
agent-browser fill @e7 "query"
agent-browser press Enter
agent-browser screenshot out.png
agent-browser close
```

Refs `@eN` come from the latest `snapshot`. Traditional CSS selectors also work (`agent-browser click "#submit"`).

## Reading the page

- `agent-browser snapshot -i` — compact accessibility tree, best for agent reasoning
- `agent-browser get text @e1` / `get html @e1` / `get value @e1` / `get title` / `get url`
- `agent-browser eval '<js>'` (`--stdin` for piped JS)

## Finding elements semantically

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "me@example.com"
```

## Checks

`agent-browser is visible|enabled|checked <sel>` — exit code reflects state.

## Batch (avoid per-command startup)

```bash
agent-browser batch "open https://example.com" "snapshot -i" "click @e1"
```

## Everything else

`agent-browser --help` and `agent-browser <cmd> --help` for the full list (waits, tabs, uploads, pdf, recording, sessions). Prefer one-shot commands composed with shell over large eval blobs.
