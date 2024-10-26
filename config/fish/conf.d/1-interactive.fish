if not status is-interactive
  exit
end

set fish_greeting  # Disable greeting on startup

if type -q zoxide
  zoxide init fish | source
end
if type -q starship
  starship init fish --print-full-init | source
end
if type -q fzf
  fzf --fish | source
end

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
abbr --add m mise
abbr --add dco "docker compose"
abbr --add g git
abbr --add j just
abbr --add l ls
abbr --add po poetry
abbr --add py python3
abbr --add rmt trash
abbr --add c z

alias cd z
alias dir-size 'du -sh'
alias git-root 'cd $(git rev-parse --show-toplevel)'
alias ls "eza --icons --all"
alias ll "ls --long"
alias posix 'exec bash -c "$argv; exec fish"'
