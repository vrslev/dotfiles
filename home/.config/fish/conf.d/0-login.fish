if not status is-login
  exit
end

set -x MISE_CACHE_DIR ~/Library/Caches/mise  # Fix mise when running `parallel`
set -x MISE_FISH_AUTO_ACTIVATE "0" # Disable auto-activation script coming from brew

if type -q /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
  set --global --export CPPFLAGS "-I$HOMEBREW_PREFIX/include";
  set --global --export LDFLAGS "-L$HOMEBREW_PREFIX/lib";
else
  echo "brew not found"
end
