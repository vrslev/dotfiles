# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [WezTerm](https://wezfurlong.org/wezterm/), [Fish](https://fishshell.com).

Here are:

- Scripts at [`bin`](bin).
- Always-fresh-and-tidy configuration for development tools at [`config`](config). Most of the files [are linked](./link-config-files) to `~/.config`. Also [`Brewfile`](Brewfile).
- macOS defaults at [`set-macos-defaults`](set-macos-defaults) that make using it snappier and less annoying.

## Getting started

Install [Homebrew](https://brew.sh):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Set up Fish:

```sh
brew install fish
sudo /bin/bash -c "echo /opt/homebrew/bin/fish >>/etc/shells"
chsh -s /opt/homebrew/bin/fish
```

Restart your shell, then clone this repository:

```sh
mkdir code
git clone https://github.com/vrslev/dotfiles code/dotfiles
cd code/dotfiles
```

Install dotfiles:

```sh
./bin/sync-deps
./link-config-files
sudo ./set-macos-defaults
```

Restart the computer to apply macOS defaults.
