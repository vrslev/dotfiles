My dotfiles: macOS, Wezterm, Fish, Neovim and VS Code.

Install Homebrew and Fish:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install fish
chsh -s /opt/homebrew/bin/fish
```

Install dotfiles:

```sh
cd
mkdir code

git clone https://github.com/vrslev/dotfiles code/dotfiles
cd code/dotfiles

make link
make install-personal  # or make install-work
make macos
```
