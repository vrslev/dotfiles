---
name: mattermost
description: Read, search, and summarize Mattermost messages, threads, channels, and mentions via the `mm` CLI. Use when the user mentions Mattermost, pastes a Mattermost permalink (e.g. `https://mattermost.*/.../pl/<post-id>`), asks to summarize a thread/discussion, search messages, list unread/mentions, or read a DM/channel.
---

# Mattermost

Use the `mm` CLI (package `mattermost-cli`). JSON output by default — good for parsing. Pass `--human` for markdown.

## Permalinks

`https://mattermost.<host>/<team>/pl/<post-id>` → the trailing segment is the post ID. Feed it to `mm thread`.

```bash
mm thread <post-id>
```

## Common commands

```bash
mm overview                     # mentions + unread + active channels
mm unread
mm mentions
mm channels
mm messages <channel>           # or @username for DM, --since 1h
mm thread <post-id>
mm search "deployment issue"
mm whoami
```

## Help

```bash
mm --help
mm <command> --help
```

## Auth

Credentials at `~/.config/mm/config.json` (managed by `mm login`). If `mm whoami` fails, ask the user to re-login — do not attempt interactive login from an agent shell.
