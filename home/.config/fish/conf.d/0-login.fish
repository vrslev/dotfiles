if not status is-login
  exit
end

set -x MISE_CACHE_DIR ~/Library/Caches/mise  # Fix mise when running parallel
set -x MISE_FISH_AUTO_ACTIVATE "0" # Disable auto-activation script coming from brew

if type -q /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
else
  echo "brew not found"
end

# make sure VS Code can detect tools
if not status is-interactive
  if type -q mise
    if not set --query DIRENV_INITIALIZED
      mise hook-env --shell fish | source
    end
  else
    echo "mise not found"
  end
end
