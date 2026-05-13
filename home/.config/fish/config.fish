if status is-login
  set -x MISE_CACHE_DIR ~/Library/Caches/mise  # Fix mise when running `parallel`
  set -x MISE_FISH_AUTO_ACTIVATE "0" # Disable auto-activation script coming from brew

  if type -q /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
    set --global --export CPPFLAGS "-I$HOMEBREW_PREFIX/include";
    set --global --export LDFLAGS "-L$HOMEBREW_PREFIX/lib";
  else
    echo "brew not found"
  end
end

if status is-interactive
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
end
