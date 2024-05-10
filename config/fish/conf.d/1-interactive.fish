
if not status is-interactive; or not test -f /opt/homebrew/bin/brew
  exit
end

set fish_greeting  # Disable greeting on startup

zoxide init fish | source
starship init fish --print-full-init | source
fzf --fish | source

function brew
  command brew $argv; and\
  switch $argv[1]
    case install uninstall reinstall tap untap
      brew-dump
  end
end

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
