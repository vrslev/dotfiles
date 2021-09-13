eval "$(/opt/homebrew/bin/brew shellenv)"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi
