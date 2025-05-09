# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [Ghostty](https://ghostty.org/), [Fish](https://fishshell.com).

Here are:

- Scripts at [`bin`](bin).
- Always-fresh-and-tidy configuration for development tools at [`home`](home). All the files are [linked](link-config-files) to user home directory. Dev tools and environment are defined in [`Brewfile`](Brewfile) and [mise config](home/.config/mise/config.toml)
- macOS defaults at [`set-macos-defaults`](set-macos-defaults) that make using it snappier and less annoying.

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
