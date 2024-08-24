# Lev's dotfiles

I use macOS, [Visual Studio Code](https://code.visualstudio.com), [WezTerm](https://wezfurlong.org/wezterm/), [Fish](https://fishshell.com).

Here are:

- Scripts at [`bin`](bin).
- Always-fresh-and-tidy configuration for development tools at [`config`](config). Most of the files [are linked](./link-config-files) to `~/.config`. Also [`Brewfile`](Brewfile).
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

Install dependencies for the first time:

```sh
eval (/opt/homebrew/bin/brew shellenv)
/opt/homebrew/bin/brew bundle --file Brewfile --no-restart
```

Install dotfiles:

```sh
./link-config-files
./sync-deps
sudo ./set-macos-defaults
```

Restart the computer to apply macOS defaults.
