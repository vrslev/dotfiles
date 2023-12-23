# Init brew env
if test -f /opt/homebrew/bin/brew
    # arm64
    eval (/opt/homebrew/bin/brew shellenv)
end

# Preferred editor for local and remote sessions
if test -n $SSH_CONNECTION
    set -x EDITOR code
else
    set -x EDITOR nano
end

starship init fish | source
wezterm shell-completion --shell fish | source

# Add pipx binaries
set -x PATH ~/.local/bin $PATH
# Add scipts
set -x PATH ~/code/dotfiles/bin $PATH
# Add cargo
set -x PATH ~/.cargo/bin $PATH

# Add python interpreters provided by hatch
for dir in ~/Library/Application\ Support/hatch/pythons/*/python/bin
    set -x PATH $dir $PATH
end

# Prevent python from writing byte code
set -x PYTHONDONTWRITEBYTECODE 1
# Set language
set -x LANG en_US.UTF-8
set -x LANGUAGE $LANG
set -x LC_ALL $LANG
# Set non-legacy mode for fish plugin jethrokuan/fzf
set -U FZF_LEGACY_KEYBINDINGS 0

set -x GOPATH ~/.go

set -x HOMEBREW_BUNDLE_NO_LOCK 1

set -x DARK_MODE (defaults read -globalDomain AppleInterfaceStyle 2>/dev/null | grep Dark)

if [ "$DARK_MODE" = "Dark" ]
    set -x BAT_THEME "Visual Studio Dark+"
else
    set -x BAT_THEME GitHub
end

# No greeting when starting an interactive shell
function fish_greeting
end


# Add !! and !$
# https://github.com/fish-shell/fish-shell/issues/288#issuecomment-591679913
function bind_bang
    switch (commandline --current-token)[-2]
    case "!"
        commandline --current-token -- $history[1]
        commandline --function repaint
    case "*"
        commandline --insert !
    end
end

function bind_dollar
    switch (commandline --current-token)[-1]
    case "*!\\"
        commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
        commandline --insert '$'
    case "!"
        commandline --current-token ""
        commandline --function history-token-search-backward

    case "*!"
        commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
        commandline --function history-token-search-backward
    case "*"
        commandline --insert '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end

alias ls "exa --icons"
alias l ls
alias v nvim
alias venv virtualenv
alias b bat
alias py python3
alias gen-py ~/code/python-template/generate.py

abbr g git
abbr pc pre-commit
abbr dco "docker compose"

# Created by `userpath` on 2023-12-17 08:23:29
set PATH $PATH /Users/lev/Library/Application Support/hatch/pythons/bins/3.8/python/bin

# Created by `userpath` on 2023-12-17 08:23:33
set PATH $PATH /Users/lev/Library/Application Support/hatch/pythons/bins/3.9/python/bin

# Created by `userpath` on 2023-12-17 08:27:32
set PATH $PATH /Users/lev/Library/Application Support/hatch/pythons/pypy2.7/pypy2.7-v7.3.12-macos_arm64/bin

# Created by `userpath` on 2023-12-17 08:27:36
set PATH $PATH /Users/lev/Library/Application Support/hatch/pythons/pypy3.9/pypy3.9-v7.3.12-macos_arm64/bin

# Created by `userpath` on 2023-12-17 08:27:41
set PATH $PATH /Users/lev/Library/Application Support/hatch/pythons/pypy3.10/pypy3.10-v7.3.12-macos_arm64/bin
