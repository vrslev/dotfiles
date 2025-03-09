if not status is-login
  exit
end

if type -q /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
else
  echo "brew not found"
end

# make sure VS Code can detect tools
if type -q mise
  if not set --query DIRENV_INITIALIZED
    mise hook-env --shell fish | source
    # Fix mise when running parallel
    set -x MISE_CACHE_DIR ~/Library/Caches/mise
  end
else
  echo "mise not found"
end
