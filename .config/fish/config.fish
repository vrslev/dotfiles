if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Init brew env
if test -f /usr/local/bin/brew
    # intel
    eval (/usr/local/bin/brew shellenv)
end

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

eval (pyenv init --path)
eval (starship init fish)

# Add pipx binaries
set -x PATH $HOME/.local/bin $PATH
# Add scipts
set -x PATH $HOME/bin $PATH
# Prevent python from writing byte code
set -x PYTHONDONTWRITEBYTECODE 1

# No greeting when starting an interactive shell
function fish_greeting
end

function bind_bang
    switch (commandline --current-token)[-1]
    case "!"
        # Without the `--`, the functionality can break when completing
        # flags used in the history (since, in certain edge cases
        # `commandline` will assume that *it* should try to interpret
        # the flag)
        commandline --current-token -- $history[1]
        commandline --function repaint
    case "*"
        commandline --insert !
    end
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

alias ls=exa
alias bake="docker buildx bake"
alias venv=virtualenv
if test -f /usr/local/bin/brew 
  alias ibrew 'arch -x86_64 /usr/local/bin/brew'
end
alias df=duf

# https://github.com/jhillyerd/plugin-git/blob/44a1eb5856cea43e4c01318120c1d4e1823d1e34/functions/__git.init.fish#L3
function __abbr
    set -l name $argv[1]
    set -l body $argv[2..-1]
    abbr -a $name $body
    set -a __git_plugin_abbreviations $name
end

__abbr g git
__abbr pc pre-commit
__abbr dco "docker compose"
