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
It then checks Fish startup and the essential commands. Run the check separately with
`mise run dotfiles:check-shell-tools`.

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

## Mail merge request review

`open-mail-mrs` groups the summary and browser tabs by the first Jira key found in each MR title or branch name, with unlinked MRs grouped together. MRs assigned to your authenticated GitLab user open in a separate Safari window; reviewer assignments and authorship alone do not count. Existing draft and notification filters still apply. Each MR opens with its diff and linked Jira issues. Tabs load one at a time in the background window, selecting each once instead of repeatedly cycling through pending tabs. Notifications are cleared only after all windows finish loading, allowing up to 15 minutes per window. Offscreen lazy-loading spinners do not block already rendered diffs. Unavailable GitLab pages are reported while the remaining pages and windows continue loading; any loading failure preserves all mail notifications. Use `--dry-run` to preview the groups without opening windows or clearing mail, or `--keep-mail` to open and check the pages without marking or moving notifications.

Set `OPEN_MAIL_MRS_IGNORED_PROJECTS` to a space-separated list of repository paths in the ignored `~/.config/mise/.env` file. For those repositories, `open-mail-mrs` skips threads containing only opening, reviewer assignment, approval, or merge notifications, except for your own MRs. When unset, all repositories are included.

## Codex projects

See [project reconciliation](docs/codex-projects.md) for product folders, separate package projects, and automatic additions after repository sync.

## Personal writing skill

[`writing-style`](home/.agents/skills/writing-style/SKILL.md) guides drafts in my voice, with Russian and English examples and notes on its evidence. Mise installs it at `~/.agents/skills/writing-style`. Invoke it with `$writing-style`, or ask Codex to write in my style. Refinements use my own corrections and human-authored prose, excluding generated or assisted drafts.
