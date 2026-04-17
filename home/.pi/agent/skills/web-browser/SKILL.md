---
name: web-browser
description: Drive Chrome from the shell to browse, click, fill forms, run JS, and screenshot. Use for dynamic sites, web UIs, or content curl cannot reach.
---

# Web Browser Skill

Uses [rodney](https://github.com/simonw/rodney) — a small Chrome CLI. One command per action, Chrome persists between calls.

## Typical flow

```bash
rodney start                   # --show to see the window
rodney open https://example.com
rodney waitload
rodney text "h1"
rodney click "a.more"
rodney input "#q" "query"
rodney submit "form"
rodney screenshot out.png
rodney stop
```

Selectors are CSS. Use `rodney js '<expr>'` (single-quoted) for anything CSS cannot express.

## Reading the page

- `rodney ax-tree --json` — accessibility tree, best for reasoning about layout
- `rodney html [sel]`, `rodney text <sel>`, `rodney attr <sel> <name>`
- `rodney js '...'` for structured extraction

## Checks (exit codes)

`rodney exists <sel>`, `rodney visible <sel>`, `rodney assert <expr> [expected]` — exit `1` on failed check, `2` on error. Chain with `&&` / `||`.

## Everything else

Run `rodney --help` for the full command list (waits, tabs, files, downloads, pdf, accessibility queries). Prefer one-shot commands composed with shell over large JS blobs.
