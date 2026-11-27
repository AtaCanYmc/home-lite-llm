_hlm_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cmds="up down restart status logs health validate doctor models test-api dsh version backup restore help"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
  fi
}

complete -F _hlm_completions hlm
