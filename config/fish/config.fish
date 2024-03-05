# $PATH and essentials
if test -f /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
    set -gx CPPFLAGS -I/opt/homebrew/include -L/opt/homebrew/lib
end

set pythons ~/Library/Application\ Support/hatch/pythons/*/python/bin

fish_add_path ~/code/dotfiles/bin\
    ~/.local/bin\
    ~/.cargo/bin\
    ~/.rd/bin\
    pythons[-1..1]

zoxide init fish | source
starship init fish | source

if test -f ~/.fish_profile
  source ~/.fish_profile
end

function fish_greeting # No greeting when starting an interactive shell
end

# Environment variables
if test -n $SSH_CONNECTION
    set -gx EDITOR code
else
    set -gx EDITOR nano
end

set -gx PYTHONDONTWRITEBYTECODE 1
set -gx LANG en_US.UTF-8
set -gx LANGUAGE $LANG
set -gx LC_ALL $LANG
set -gx GOPATH ~/.go
set -gx HOMEBREW_BUNDLE_NO_LOCK 1

set -gx DARK_MODE (defaults read -globalDomain AppleInterfaceStyle 2>/dev/null)

if test "$DARK_MODE" = Dark
    set -gx BAT_THEME Visual Studio Dark+
    set -gx DELTA_FEATURES dark
else
    set -gx BAT_THEME GitHub
    set -gx DELTA_FEATURES light
end

# Aliases and abbreviations

# Add !$ (https://github.com/fish-shell/fish-shell/issues/288#issuecomment-591679913)
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

bind ! bind_bang
bind '$' bind_dollar

alias ls "exa --icons"
alias l ls
alias ll "ls --long --all"
alias cd z
alias c z
alias ca bat
alias pip "uv pip"
alias venv "uv venv"
alias python python3
alias py python3
alias gr 'cd $(git rev-parse --show-toplevel)'

abbr g git
abbr pc pre-commit
abbr dco "docker compose"
abbr po poetry
abbr j just
