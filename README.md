# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [Ghostty](https://ghostty.org/), [Fish](https://fishshell.com).

## Notable places

- [`bin`](bin)
- [`home/.pi/agent`](home/.pi/agent)
- [`home/Library/Application Support/Code (VS Code)`](home/Library/Application%20Support/Code)
- [`home/.config/mise/config.toml`](home/.config/mise/config.toml)
- [`Brewfile`](Brewfile)
- [`home/.config/git`](home/.config/git)

## Getting started

Open terminal and install [Homebrew](https://brew.sh):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Set up Fish:

```sh
/opt/homebrew/bin/brew install fish
sudo /bin/bash -c "echo /opt/homebrew/bin/fish >>/etc/shells"
chsh -s /opt/homebrew/bin/fish
```

Open another terminal tab and clone this repository:

```sh
mkdir code
git clone https://github.com/vrslev/dotfiles code/dotfiles
cd code/dotfiles
```

Install [mise](https://mise.jdx.dev):

```sh
eval (/opt/homebrew/bin/brew shellenv)
brew install mise
```

Install dependencies for the first time:

```sh
eval (/opt/homebrew/bin/brew shellenv)
/opt/homebrew/bin/brew bundle --file Brewfile --no-restart
MISE_GLOBAL_CONFIG_FILE=home/.config/mise/config.toml mise up --yes --jobs 16
```

Install dotfiles:

```sh
./bin/dotfiles/link-config-files
./bin/dotfiles/sync-deps
sudo ./bin/dotfiles/set-macos-defaults
```

Restart the computer to apply macOS defaults.
