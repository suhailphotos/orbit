# modules/functions/tmux.zsh
_starship_tmux_seg() {
  if [[ -n "$TMUX" ]]; then
    if [[ "$PWD" == "$HOME" ]]; then
      export STARSHIP_TMUX_SEG='󰬛'       # at home: no surrounding spaces
    else
      export STARSHIP_TMUX_SEG=' 󰬛 '     # not home: space-prefixed & suffixed
    fi
  else
    unset STARSHIP_TMUX_SEG               # hide when not in tmux
  fi
}

# modules/functions/tmux.zsh
typeset -ag precmd_functions
if (( ${precmd_functions[(Ie)_starship_tmux_seg]} == 0 )); then
  precmd_functions+=(_starship_tmux_seg)
fi
