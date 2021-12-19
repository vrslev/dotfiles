#
# Fig environment variables (start)
#
[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh

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

# Expose pipx binaries
export PATH="$HOME/.local/bin:$PATH"

# Don't allow Hombrew to collect analytics
export HOMEBREW_NO_ANALYTICS=1

#
# Fig environment variables (end)
#
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
