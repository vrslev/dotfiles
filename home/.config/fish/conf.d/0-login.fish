if not status is-login
  exit
end

set -x MISE_CACHE_DIR ~/Library/Caches/mise  # Fix mise when running `parallel`
set -x MISE_FISH_AUTO_ACTIVATE "0" # Disable auto-activation script coming from brew

if type -q /opt/homebrew/bin/brew
  # /opt/homebrew/bin/brew shellenv | pbcopy
  set --global --export HOMEBREW_PREFIX "/opt/homebrew";
  set --global --export HOMEBREW_CELLAR "/opt/homebrew/Cellar";
  set --global --export HOMEBREW_REPOSITORY "/opt/homebrew";
  fish_add_path --global --move --path "/opt/homebrew/bin" "/opt/homebrew/sbin";
  if test -n "$MANPATH[1]"; set --global --export MANPATH '' $MANPATH; end;
  if not contains "/opt/homebrew/share/info" $INFOPATH; set --global --export INFOPATH "/opt/homebrew/share/info" $INFOPATH; end;
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
