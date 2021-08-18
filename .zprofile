eval "$(/opt/homebrew/bin/brew shellenv)"

# nvm slows shell for 1-2 seconds
alias load_nvm='[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"'

# Load brew completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

alias pip="pip3"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

export PATH="/opt/homebrew/opt/node@12/bin:$PATH"