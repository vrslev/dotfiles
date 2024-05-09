# Essentials
set fish_greeting  # Disable greeting when startup

if ! test -f /opt/homebrew/bin/brew
  echo No brew installed!
  exit 1
end

/opt/homebrew/bin/brew shellenv | source
mise activate fish | source
zoxide init fish | source
starship init fish | source
fzf --fish | source

fish_add_path ~/code/dotfiles/bin ~/.rd/bin
if test -f ~/.fish_profile
  source ~/.fish_profile
end

set -gx LANG en_US.UTF-8
set -gx LANGUAGE $LANG
set -gx LC_ALL $LANG
set -gx EDITOR code

set -gx CPPFLAGS -I/opt/homebrew/include -L/opt/homebrew/lib
set -gx PYTHONDONTWRITEBYTECODE 1

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

# Aliases and abbreviations
function __last_history_item
  echo $history[1]
end
abbr -a !! --position anywhere --function __last_history_item

function __last_history_arg
  commandline -f backward-delete-char
  commandline -f history-token-search-backward
end
abbr -a !\$ --position anywhere --function __last_history_arg

alias ls "eza --icons"
alias ll "ls --long --all"
alias cd z
alias c z
alias python python3
alias venv "uv venv"
alias gr 'cd $(git rev-parse --show-toplevel)'
alias ds 'du -sh'
alias posix 'exec bash -c "$argv; exec fish"'

abbr b brew
abbr dco "docker compose"
abbr g git
abbr j just
abbr l ls
abbr pc pre-commit
abbr po poetry
abbr py python3
abbr t task
abbr tra trash
