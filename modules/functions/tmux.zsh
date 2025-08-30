# modules/functions/tmux.zsh
_starship_tmux_seg() {
  # choose glyph (allow ASCII fallback if needed)
  local sym=''
  [[ ${ORBIT_PROMPT_ASCII:-0} -eq 1 ]] && sym='x'

  if [[ -n $TMUX ]]; then
    if [[ $PWD == $HOME ]]; then
      export STARSHIP_TMUX_SEG="${sym}"       # no extra spaces at home
    else
      export STARSHIP_TMUX_SEG=" ${sym} "     # pad on both sides elsewhere
    fi
  else
    unset STARSHIP_TMUX_SEG
  fi
}
precmd_functions+=(_starship_tmux_seg)
