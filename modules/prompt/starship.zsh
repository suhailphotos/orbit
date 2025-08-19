# modules/prompt/starship.zsh
# Initialize Starship prompt (interactive shells only)
[[ -o interactive ]] || return 0

# Config path
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml}"

# Derive a clean poetry/venv name once per prompt (no external commands)
_prompt_set_py_name() {
  emulate -L zsh
  setopt extended_glob
  unset PROMPT_PY_ENV_NAME

  if [[ -n ${VIRTUAL_ENV:-} ]]; then
    local base="${VIRTUAL_ENV:t}"

    # In-project .venv -> use cwd basename
    if [[ $base == ".venv" ]]; then
      PROMPT_PY_ENV_NAME="${PWD:t}"
    else
      # Strip trailing "-pyX[.Y[.Z]]"
      local clean="${base%-py[0-9.]##}"
      # Strip trailing "-<hash>" (typical Poetry)
      if [[ $clean == *-[A-Za-z0-9]## ]]; then
        clean="${clean%-[A-Za-z0-9]##}"
      fi
      # If it still prefixes the cwd name, snap to cwd
      [[ $clean == ${PWD:t}-* ]] && clean="${PWD:t}"
      PROMPT_PY_ENV_NAME="$clean"
    fi

    export PROMPT_PY_ENV_NAME
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_set_py_name

_no_flash_clear() {
  # begin synchronized update (terminals that don't support it just ignore)
  printf '\e[?2026h'
  # hide cursor so the clear/redraw doesn't "blink"
  printf '\e[?25l'
  # clear screen (no scrollback) and home
  printf '\e[H\e[2J'
  zle redisplay
  # show cursor and end sync update
  printf '\e[?25h\e[?2026l'
}
zle -N _no_flash_clear
bindkey '^L' _no_flash_clear        # Ctrl+L uses the no-flash clear
# optional: make the `clear` command behave the same
alias clear='_no_flash_clear'


# Init Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  return 1
fi
