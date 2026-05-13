if not status is-interactive
  exit
end

set fish_greeting  # Disable greeting on startup

if type -q mise
  mise activate fish | source
end
if type -q zoxide
  zoxide init fish | source
end
if type -q starship
  starship init fish --print-full-init | source
end
if type -q fzf
  fzf --fish | source
end

alias cd z
alias posix 'exec bash -c "$argv; exec fish"'

function beep
  if test "$status" = "0"
    afplay "/System/Library/Sounds/Glass.aiff"
  else
    afplay "/System/Library/Sounds/Basso.aiff"
  end
end
