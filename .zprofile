# Init brew env
if [[ -f /opt/homebrew/bin/brew ]]; then
    # arm64
    eval $(/opt/homebrew/bin/brew shellenv)
elif [[ -f /usr/local/bin/brew ]]; then
    # intel
    eval $(/usr/local/bin/brew shellenv)
fi

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nano'
else
    export EDITOR='code'
fi

# Init pyenv env
eval "$(pyenv init --path)"
