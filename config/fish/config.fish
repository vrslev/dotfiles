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

rtx activate fish | source
starship init fish | source
zoxide init fish | source
wezterm shell-completion --shell fish | source

# Add pipx binaries
set -x PATH $HOME/.local/bin $PATH
# Add scipts
set -x PATH ~/code/dotfiles/bin $PATH
# Add cargo
set -x PATH $HOME/.cargo/bin $PATH
# Prevent python from writing byte code
set -x PYTHONDONTWRITEBYTECODE 1
# Set language
set -x LANG en_US.UTF-8
set -x LANGUAGE $LANG
set -x LC_ALL $LANG
# Set non-legacy mode for fish plugin jethrokuan/fzf
set -U FZF_LEGACY_KEYBINDINGS 0

set -x DARK_MODE (defaults read -globalDomain AppleInterfaceStyle 2>/dev/null | grep Dark)

if [ "$DARK_MODE" = "Dark" ]
    set -x BAT_THEME "Visual Studio Dark+"
else
    set -x BAT_THEME GitHub
end

set -x PIPX_DEFAULT_PYTHON "$(rtx which python)"

# No greeting when starting an interactive shell
function fish_greeting
end


# Add !! and !$
# https://github.com/fish-shell/fish-shell/issues/288#issuecomment-591679913
function bind_bang
    switch (commandline --current-token)[-1]
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
alias bake "docker buildx bake"
alias venv virtualenv
alias df duf
alias v nvim
alias b bat
alias watch viddy
alias cd z

abbr g git
abbr pc pre-commit
abbr dco "docker compose"
