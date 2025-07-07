if not status is-interactive
  exit
end
if test -n "$VSCODE_RESOLVING_ENVIRONMENT"
  exit
end

set fish_greeting  # Disable greeting on startup

if type -q mise
  mise activate fish | source
end
if type -q zoxide
  zoxide init fish | source
end
set -x _STARSHIP_INIT 1
if test -n _STARSHIP_INIT && type -q starship
  starship init fish --print-full-init | source
end
if type -q fzf
  fzf --fish | source
end

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
