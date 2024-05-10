My dotfiles: macOS, Wezterm, Fish, Neovim and VS Code.

Install Homebrew:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Set up Fish:

```sh
brew install fish
sudo /bin/bash -c "echo /opt/homebrew/bin/fish >>/etc/shells"
chsh -s /opt/homebrew/bin/fish
```

Install dotfiles:

```sh
cd
mkdir code

git clone https://github.com/vrslev/dotfiles code/dotfiles
cd code/dotfiles

make install-personal  # or make install-work
make macos
make link
```
