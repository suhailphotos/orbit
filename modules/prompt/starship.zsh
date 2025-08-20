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

# Not home flag for the folder icon
starship_precmd_not_home() {
  if [[ "$PWD" == "$HOME" ]]; then
    unset STARSHIP_NOT_HOME
  else
    export STARSHIP_NOT_HOME=1
  fi
}
typeset -ag precmd_functions
precmd_functions+=starship_precmd_not_home

# Init Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  return 1
fi
