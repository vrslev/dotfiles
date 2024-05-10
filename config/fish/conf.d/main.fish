if ! test -f /opt/homebrew/bin/brew
  echo No brew installed!
  exit 1
end

set fish_greeting  # Disable greeting on startup
set -gx LANG en_US.UTF-8
set -gx LANGUAGE $LANG
set -gx LC_ALL $LANG
set -gx EDITOR code
set -gx PYTHONDONTWRITEBYTECODE 1

# ----
/opt/homebrew/bin/brew shellenv | source
set -gx HOMEBREW_BUNDLE_NO_LOCK 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1
set -gx CPPFLAGS -I/opt/homebrew/include -L/opt/homebrew/lib

function brew
  command brew $argv; and\
  switch $argv[1]
    case install uninstall tap untap
      brew-dump
  end
end

zoxide init fish | source
starship init fish --print-full-init | source
fzf --fish | source
fish_add_path (dirname (dirname (dirname (readlink (dirname (status --current-filename))))))/bin ~/.rd/bin

# ---
function __last_history_item
  echo $history[1]
end
abbr -a !! --position anywhere --function __last_history_item

function __last_history_arg
  commandline -f backward-delete-char
  commandline -f history-token-search-backward
end
abbr -a !\$ --position anywhere --function __last_history_arg

abbr b brew
abbr dco "docker compose"
abbr g git
abbr j just
abbr l ls
abbr pc pre-commit
abbr po poetry
abbr py python3
abbr t task
abbr tra trash

alias c z
alias cd z
alias ds 'du -sh'
alias gr 'cd $(git rev-parse --show-toplevel)'
alias ll "ls --long --all"
alias ls "eza --icons"
alias posix 'exec bash -c "$argv; exec fish"'
alias python python3
alias venv "uv venv"
