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
  dotenv
  gh
  git
  npm
  pip
  pyenv
  python
  sudo
  virtualenv
  zsh-autosuggestions
  zsh-interactive-cd
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

#
# Initialize some tools
#

eval "$(starship init zsh)"
eval "$(pyenv init -)"

#
# Autocompletions
#

if type brew &>/dev/null; then
  # load main completions for packages installed with brew
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit

  # load fzf completions
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  # load fzf key bindings
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
  # load yc completions
  source "$(brew --prefix)/Caskroom/yandex-cloud-cli/latest/yandex-cloud-cli/completion.zsh.inc"
fi

#
# Fig environment variables (end)
#
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh

#
# Aliases
#

unalias py # "python" oh-my-zsh plugin has intersecting alias with python-launcher
alias pip=pip3
alias ls=exa

if [[ -f /usr/local/bin/brew ]]; then
  alias ibrew='arch -x86_64 /usr/local/bin/brew'
fi
