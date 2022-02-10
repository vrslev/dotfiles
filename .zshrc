#
# Fig environment variables (start)
#
[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh

#
# oh-my-zsh configuration
#

export ZSH="$HOME/.oh-my-zsh"

ZSH_DISABLE_COMPFIX=true

plugins=(
  colored-man-pages
  command-not-found
  docker
  docker-compose
  git
  pip
  sudo
  zsh-autosuggestions
  zsh-interactive-cd
  zsh-syntax-highlighting # https://github.com/zsh-users/zsh-syntax-highlighting
  you-should-use          # https://github.com/MichaelAquilina/zsh-you-should-use
)

source $ZSH/oh-my-zsh.sh

#
# Initialize some tools
#

eval "$(starship init zsh)"

# Lazy load pyenv
pyenv() {
  eval "$(command pyenv init -)"
  pyenv "$@"
}

#
# Autocompletions
#

zstyle ':completion:*' menu select
fpath+=~/.zfunc

if type brew &>/dev/null; then
  # load main completions for packages installed with brew
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
    compinit
  else
    compinit -C
  fi

  # load fzf completions
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  # load fzf key bindings
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
fi

#
# Aliases
#

alias pip=pip3
alias ls=exa
alias pc=pre-commit

if [[ -f /usr/local/bin/brew ]]; then
  alias ibrew='arch -x86_64 /usr/local/bin/brew'
fi

#
# Functions
#

cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]]; then
    ## If env folder is found then activate the vitualenv
    if [[ -d ./venv ]]; then
      source ./venv/bin/activate
    fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    if [[ "$PWD"/ != "$(dirname "$VIRTUAL_ENV")"/* ]]; then
      deactivate
    fi
  fi
}

#
# Fig environment variables (end)
#
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
