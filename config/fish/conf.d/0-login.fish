if not status is-login
  exit
end

if not test -f /opt/homebrew/bin/brew
  echo No brew installed!
  exit 1
end

set -gx LANG en_US.UTF-8
set -gx LANGUAGE $LANG
set -gx LC_ALL $LANG
set -gx EDITOR code
set -gx PYTHONDONTWRITEBYTECODE 1

/opt/homebrew/bin/brew shellenv | source
set -gx HOMEBREW_BUNDLE_NO_LOCK 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1
set -gx CPPFLAGS -I/opt/homebrew/include
set -gx LDFLAGS -L/opt/homebrew/lib
set -gx UV_NATIVE_TLS true
set -gx MISE_ENVIRONMENT dev  # tell mise to use ~/.config/mise/config.dev.toml

# allow vscode to detect tools
if test -z "$DIRENV_INITIALIZED"
  mise hook-env --shell fish | source
  set -gx DIRENV_INITIALIZED 1
end

set -gx DOTFILES_ROOT (dirname (dirname (dirname (readlink (dirname (status --current-filename))))))
fish_add_path -g $DOTFILES_ROOT/bin ~/.local/bin ~/.cargo/bin
