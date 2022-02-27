if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Init brew env
if test -f /opt/homebrew/bin/brew
    # arm64
    eval (/opt/homebrew/bin/brew shellenv)
else if test -f /usr/local/bin/brew
    # intel
    eval (/usr/local/bin/brew shellenv)
end

# Preferred editor for local and remote sessions
if test -n $SSH_CONNECTION
    set -x EDITOR code
else
    set -x EDITOR nano
end

# Init pyenv env
eval (pyenv init --path)

eval (starship init fish)

# Expose pipx binaries
set -x PATH $HOME/.local/bin $PATH

# No greeting when starting an interactive shell
function fish_greeting
end

alias pip=pip3
alias ls=exa
alias pc=pre-commit
alias bake="docker buildx bake"
alias venv=virtualenv

if test -f /usr/local/bin/brew 
  alias ibrew 'arch -x86_64 /usr/local/bin/brew'
end

# TODO: Poetry completions
