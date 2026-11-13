# Render Starship in a process substitution, leaving ZLE responsive.
# Until it finishes, show a builtin-only directory and status prompt.
# Retire a pending watcher before replacing its descriptor on re-source.
if (( $+functions[_herdr_prompt_close] )); then
  _herdr_prompt_close
fi
zmodload zsh/system
_herdr_starship_template=$PROMPT
unsetopt promptsubst
PROMPT='%~
%F{green}❯%f '
RPROMPT=''
typeset -gi _herdr_prompt_fd=-1 _herdr_prompt_generation=0
typeset -g _herdr_prompt_data='' _herdr_prompt_pwd=''

_herdr_prompt_close() {
  if (( _herdr_prompt_fd >= 0 )); then
    zle -F "$_herdr_prompt_fd" 2>/dev/null || true
    exec {_herdr_prompt_fd}<&-
    _herdr_prompt_fd=-1
  fi
}

_herdr_prompt_receive() {
  local chunk=''
  [[ $1 == $_herdr_prompt_fd ]] || return
  if ! sysread -i "$1" -s 65536 chunk; then
    _herdr_prompt_close
    return
  fi
  _herdr_prompt_data+=$chunk
  if [[ $_herdr_prompt_data == *$'\0'* ]]; then
    local record=${_herdr_prompt_data%%$'\0'*}
    local generation=${record%%:*}
    local rendered=${record#*:}
    _herdr_prompt_close
    # Avoid redrawing while a command is being composed.
    if [[ $generation == $_herdr_prompt_generation && $PWD == $_herdr_prompt_pwd && -z $BUFFER ]]; then
      PROMPT=$rendered
      zle reset-prompt
    fi
  fi
}

_herdr_prompt_start() {
  _herdr_prompt_close
  (( ++_herdr_prompt_generation ))
  _herdr_prompt_data=''
  _herdr_prompt_pwd=$PWD
  if [[ ${STARSHIP_CMD_STATUS:-0} == 0 ]]; then
    PROMPT='%~
%F{green}❯%f '
  else
    PROMPT='%~
%F{red}❯%f '
  fi
  exec {_herdr_prompt_fd}< <(
    local rendered=${(e)_herdr_starship_template}
    print -rn -- "$_herdr_prompt_generation:$rendered"$'\0'
  )
  zle -F -w "$_herdr_prompt_fd" _herdr_prompt_receive
}

_herdr_prompt_before_command() {
  _herdr_prompt_close
}
zle -N _herdr_prompt_receive
add-zsh-hook precmd _herdr_prompt_start
add-zsh-hook preexec _herdr_prompt_before_command
