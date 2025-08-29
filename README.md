# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [Ghostty](https://ghostty.org/), [Fish](https://fishshell.com).

## Notable places

- [`bin`](bin)
- [`Brewfile`](Brewfile)
- [`home/.config/fish`](home/.config/fish)
- [`home/.config/git`](home/.config/git)
- [`home/.config/mise`](home/.config/mise)
- [`home/Library/Application Support/Code (VS Code)`](home/Library/Application Support/Code)
- [`home/Library/Application Support/com.mitchellh.ghostty`](home/Library/Application Support/com.mitchellh.ghostty)

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
./link-config-files
./sync-deps
sudo ./set-macos-defaults
```

Restart the computer to apply macOS defaults.
