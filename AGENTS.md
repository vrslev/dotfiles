# dotfiles

macOS dotfiles for Fish, Ghostty, VS Code, Git, mise, etc. Installed via symlinks from `home/` into `$HOME`.

## Layout

- `home/` — mirrors `$HOME`. Files/dirs here are symlink sources.
- `home/.config/mise/config.toml` — canonical global mise config for tools, environment, packages, dotfiles, bootstrap state, and orchestration tasks.
- `bin/` — scripts on `$PATH`:
  - `bin/dotfiles/` — dotfiles-specific utilities that are not mise wrappers.
  - `bin/source-control/` — Git/GitLab helpers (`g`, `gen-commit-msg`, `create-glab-mr`, ...).
  - `bin/utils/` — misc utilities.
- `README.md` — first-time setup steps.

## Conventions

- Add a dotfile with `mise bootstrap dotfiles add --global ~/<path>`, or place it under `home/<path>` and add its target to `[dotfiles]` in `home/.config/mise/config.toml`.
- Remove a dotfile by removing its `[dotfiles]` entry and source from `home/`.
- Re-apply managed dotfiles with `mise bootstrap dotfiles apply --yes`.
- Python scripts: `#!/usr/bin/env -S uv run --python 3.13 --script` or `#!/usr/bin/env python3`, `# pyright: strict`, no comments unless they add info beyond the code.
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`.
- `$DOTFILES_ROOT` env var points at this repo (set by the global mise config).

## Common tasks

- Migrate this machine: `mise bootstrap --yes`
- Bootstrap a new machine: `MISE_GLOBAL_CONFIG_FILE="$PWD/home/.config/mise/config.toml" mise bootstrap --yes`
- Sync everything (pull, relink, update brew/mise): `mise run dotfiles:sync`
- List available tasks: `mise tasks`
- Check dependency/bootstrap state: `mise bootstrap status`

No tests, no Justfile.
