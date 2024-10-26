if not status is-login
  exit
end

if type -q /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
else
  echo "brew not found"
end

if type -q ~/.local/bin/mise
  if not set --query DIRENV_INITIALIZED
  ~/.local/bin/mise hook-env --shell fish | source
  end
else
  echo "mise not found"
end
