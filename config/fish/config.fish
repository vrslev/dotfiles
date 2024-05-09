# $PATH and essentials
if test -f /opt/homebrew/bin/brew
  echo No brew installed
  exit
end
/opt/homebrew/bin/brew shellenv | source

fish_add_path ~/code/dotfiles/bin ~/.rd/bin

mise activate fish | source
zoxide init fish | source
starship init fish | source
fzf --fish | source

if test -f ~/.fish_profile
  source ~/.fish_profile
end

function fish_greeting # No greeting when starting an interactive shell
end

# Enable shell integration for terminal emulators, it doesn't work by default when using starship
# https://github.com/wez/wezterm/issues/115
# https://github.com/PerBothner/DomTerm/blob/master/tools/shell-integration.fish
if status --is-interactive
  set _fishprompt_aid "fish"$fish_pid
  set _fishprompt_started 0
  # empty if running; or a numeric exit code; or CANCEL
  set _fishprompt_postexec ""

  functions -c fish_prompt _fishprompt_saved_prompt
  set _fishprompt_prompt_count 0
  set _fishprompt_disp_count 0
  function _fishprompt_start --on-event fish_prompt
    set _fishprompt_prompt_count (math $_fishprompt_prompt_count + 1)
    # don't use post-exec, because it is called *before* omitted-newline output
    if [ -n "$_fishprompt_postexec" ]
      printf "\033]133;D;%s;aid=%s\007" "$_fishprompt_postexec" $_fishprompt_aid
    end
    printf "\033]133;A;aid=%s;cl=m\007" $_fishprompt_aid
  end

  function fish_prompt
    set _fishprompt_disp_count (math $_fishprompt_disp_count + 1)
    printf "\033]133;P;k=i\007%b\033]133;B\007" (string join "\n" (_fishprompt_saved_prompt))
    set _fishprompt_started 1
    set _fishprompt_postexec ""
  end

  function _fishprompt_preexec --on-event fish_preexec
    if [ "$_fishprompt_started" = "1" ]
      printf "\033]133;C;\007"
    end
    set _fishprompt_started 0
  end

  function _fishprompt_postexec --on-event fish_postexec
     set _fishprompt_postexec $status
    _fishprompt_start
  end

  function __fishprompt_cancel --on-event fish_cancel
     set _fishprompt_postexec CANCEL
    _fishprompt_start
  end

  function _fishprompt_exit --on-process %self
    if [ "$_fishprompt_started" = "1" ]
      printf "\033]133;Z;aid=%s\007" $_fishprompt_aid
    end
  end

  if functions -q fish_right_prompt
    functions -c fish_right_prompt _fishprompt_saved_right_prompt
    function fish_right_prompt
       printf "\033]133;P;k=r\007%b\033]133;B\007" (string join "\n" (_fishprompt_saved_right_prompt))
    end
  end
end

# Environment variables
if test -n $SSH_CONNECTION
    set -gx EDITOR code
else
    set -gx EDITOR nano
end

set -gx PYTHONDONTWRITEBYTECODE 1
set -gx LANG en_US.UTF-8
set -gx LANGUAGE $LANG
set -gx LC_ALL $LANG
set -gx GOPATH ~/.go
set -gx HOMEBREW_BUNDLE_NO_LOCK 1

# Aliases and abbreviations

# Add !$ (https://github.com/fish-shell/fish-shell/issues/288#issuecomment-591679913)
function bind_bang
    switch (commandline --current-token)[-2]
    case "!"
        commandline --current-token -- $history[1]
        commandline --function repaint
    case "*"
        commandline --insert !
    end
end

function bind_dollar
    switch (commandline --current-token)[-1]
    case "*!\\"
        commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
        commandline --insert '$'
    case "!"
        commandline --current-token ""
        commandline --function history-token-search-backward

    case "*!"
        commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
        commandline --function history-token-search-backward
    case "*"
        commandline --insert '$'
    end
end

bind ! bind_bang
bind '$' bind_dollar

alias ls "eza --icons"
alias l ls
alias ll "ls --long --all"
alias cd z
alias c z
alias ca bat
alias pip "uv pip"
alias venv "uv venv"
alias python python3
alias py python3
alias gr 'cd $(git rev-parse --show-toplevel)'
alias ds 'du -sh'
alias posix 'exec bash -c "$argv; exec fish"'
alias stop-docker 'rdctl shutdown'

abbr g git
abbr pc pre-commit
abbr dco "docker compose"
abbr po poetry
abbr j just
