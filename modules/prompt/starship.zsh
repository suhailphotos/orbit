# modules/prompt/starship.zsh
# Initialize Starship prompt (interactive shells only)
[[ -o interactive ]] || return 0

# Config path
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml}"

# Derive a stable env name from VIRTUAL_ENV (never from $PWD)
_prompt_set_py_name() {
  emulate -L zsh
  setopt extended_glob
  unset PROMPT_PY_ENV_NAME

  [[ -n ${VIRTUAL_ENV:-} ]] || return

  local envpath="${VIRTUAL_ENV:A}"
  local base="${envpath:t}"
  local name=""

  if [[ $base == ".venv" ]]; then
    name="${envpath:h:t}"           # project folder that owns .venv
  else
    name="$base"
    name="${name%-py[0-9.]##}"      # strip -py3.x
    if [[ $name == *-[A-Za-z0-9]## ]]; then
      name="${name%-[A-Za-z0-9]##}" # strip trailing hash
    fi
  fi

  export PROMPT_PY_ENV_NAME="$name"
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
