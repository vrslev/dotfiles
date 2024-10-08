if not status is-interactive; or not test -f /opt/homebrew/bin/brew
  exit
end

set fish_greeting  # Disable greeting on startup

zoxide init fish | source
starship init fish --print-full-init | source
fzf --fish | source

function __last_history_item
  echo $history[1]
end
abbr --add !! --position anywhere --function __last_history_item

function __last_history_arg
  commandline -f backward-delete-char
  commandline -f history-token-search-backward
end
abbr --add !\$ --position anywhere --function __last_history_arg

abbr --add b brew
abbr --add dco "docker compose"
abbr --add g git
abbr --add j just
abbr --add l ls
abbr --add pc pre-commit
abbr --add po poetry
abbr --add py python3
abbr --add tra trash

alias c z
alias cd z
alias ds 'du -sh'
alias gr 'cd $(git rev-parse --show-toplevel)'
alias ls "eza --icons --all"
alias ll "ls --long"
alias posix 'exec bash -c "$argv; exec fish"'
alias python python3
alias venv "uv venv"
