# dotfiles

macOS dotfiles for Fish, Ghostty, VS Code, Git, mise, etc. Installed via symlinks from `home/` into `$HOME`.

## Layout

- `home/` — mirrors `$HOME`. Files/dirs here are symlink sources.
- `symlinks.json` — flat list of `~/...` paths to symlink. Each must exist under `home/<same relative path>`.
- `link-config-files` — Python script. Creates symlinks per `symlinks.json`; warns on mismatches; reports untracked files in `home/`.
- `Brewfile` — Homebrew deps. Updated by `bin/dotfiles/brew-dump` (runs on `brew cleanup` via a hook).
- `bin/` — scripts on `$PATH`:
  - `bin/dotfiles/` — repo maintenance (`sync-deps`, `sync-dotfiles`, `track-dotfile`, `untrack-dotfile`, `set-macos-defaults`, `brew-dump`, ...).
  - `bin/source-control/` — Git/GitLab helpers (`g`, `gen-commit-msg`, `create-glab-mr`, ...).
  - `bin/utils/` — misc utilities.
- `README.md` — first-time setup steps.

## Conventions

- Add a dotfile: place under `home/<path>`, then either edit `symlinks.json` or run `track-dotfile ~/<path>`. Then run `./link-config-files`.
- Remove a dotfile: `untrack-dotfile ~/<path>`.
- Python scripts: `#!/usr/bin/env -S uv run --python 3.13 --script` or `#!/usr/bin/env python3`, `# pyright: strict`, no comments unless they add info beyond the code.
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`.
- `$DOTFILES_ROOT` env var points at this repo (set by Fish config).

## Common tasks

- Sync everything (pull, relink, update brew/mise): `bin/dotfiles/sync-dotfiles`
- Update deps only: `bin/dotfiles/sync-deps`
- Apply macOS defaults: `sudo bin/dotfiles/set-macos-defaults` (then reboot)
- Re-link after changing `symlinks.json` or adding files: `./link-config-files`

No tests, no Justfile.
