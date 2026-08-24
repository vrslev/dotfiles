# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [Codex](https://openai.com/codex/), [Ghostty](https://ghostty.org/), [Fish](https://fishshell.com), and [mise](https://mise.jdx.dev).

## Notable places

- [`home/.config/mise/config.toml`](home/.config/mise/config.toml) — global tools, environment, packages, dotfiles, macOS defaults, and sync tasks
- [`bin`](bin) — reusable commands
- [`home`](home) — files linked into `$HOME`
- [`home/Library/Application Support/Code (VS Code)`](home/Library/Application%20Support/Code)
- [`home/.config/git`](home/.config/git)

## Migrate this Mac

Once this version is checked out at `~/code/gh/vrslev/dotfiles`, migrate the existing installation with:

```sh
mise bootstrap --yes
```

Bootstrap is the migration. It installs anything missing, replaces the old linker with mise-managed symlinks, applies macOS defaults, configures Fish, and verifies the resulting state. It is safe to re-run.

Restart the Mac after the first successful migration so applications reload the managed defaults.

## Set up a new Mac

Install [Homebrew](https://brew.sh):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone this repository:

```sh
mkdir -p ~/code/gh/vrslev
git clone https://github.com/vrslev/dotfiles ~/code/gh/vrslev/dotfiles
cd ~/code/gh/vrslev/dotfiles
```

Install mise:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install mise
```

Bootstrap from the global config source before it has been linked into place:

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/home/.config/mise/config.toml" \
  mise bootstrap --yes
```

The config is global once `~/.config/mise` points to `home/.config/mise`; there is no project-local `mise.toml`. Restart the computer after the first bootstrap.

## Maintenance

The routine command to remember is:

```sh
mise run dotfiles:sync
```

It fast-forwards the repository, re-applies links, and synchronizes tools and packages.

Available tasks and read-only bootstrap status are discoverable:

```sh
mise tasks
mise bootstrap status
```

Use mise directly to manage dotfiles:

```sh
mise bootstrap dotfiles add --global ~/.example
mise bootstrap dotfiles apply --yes
```

## Caveats

- `dotfiles:sync` uses `git pull --ff-only`; it stops instead of rebasing a divergent checkout.
- Removing a package from `[bootstrap.packages]` does not uninstall it. Prune packages only when removal is intentional.
- Removing a `[dotfiles]` entry does not remove its existing target. Delete obsolete targets explicitly.
- Mise refuses conflicting dotfile targets by default. Inspect the conflict instead of reaching for `--force`.
- The config assumes this repository lives at `~/code/gh/vrslev/dotfiles`, and most versions are `latest`, so a fresh bootstrap can resolve newer software.
- Safari defaults and VS Code extensions are intentionally unmanaged.
- The official ChatGPT cask currently owns the same `/Applications/ChatGPT.app` used by Codex. An identical existing bundle can be adopted; a different bundle at that path blocks installation rather than being overwritten.
