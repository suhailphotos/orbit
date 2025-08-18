# modules/prompt/starship.zsh
# Initialize Starship prompt (interactive shells only)
[[ -o interactive ]] || return 0

# Small env bits Starship reads
case "${ORBIT_PLATFORM:-}" in
  linux) export PROMPT_CONTEXT_SUFFIX=":" ;;
  *)     unset PROMPT_CONTEXT_SUFFIX ;;
esac
: "${PROMPT_SEP:=$'\u2009'}"
export PROMPT_SEP

# Config path
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml}"

# Derive a clean poetry/venv name once per prompt (no external commands)
_prompt_set_py_name() {
  setopt localoptions extended_glob
  if [[ -n $VIRTUAL_ENV ]]; then
    local base="${VIRTUAL_ENV:t}"  # venv dir name

    # Handle in-project `.venv` -> use current dir name
    if [[ $base == ".venv" ]]; then
      PROMPT_PY_ENV_NAME="${PWD:t}"
      export PROMPT_PY_ENV_NAME
      return
    fi

    # Strip trailing "-pyX[.Y[.Z]]"
    local clean="${base%-py[0-9.]##}"

    # Strip trailing "-<hash>" (letters/digits), typical Poetry pattern
    if [[ $clean == *-[A-Za-z0-9]## ]]; then
      clean="${clean%-[A-Za-z0-9]##}"
    fi

    # If it still looks like "<proj>-..." and matches cwd, snap to cwd basename
    if [[ $clean == ${PWD:t}-* ]]; then
      clean="${PWD:t}"
    fi

    PROMPT_PY_ENV_NAME="$clean"
    export PROMPT_PY_ENV_NAME

  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    # Optional: if conda is active, show that name
    PROMPT_PY_ENV_NAME="$CONDA_DEFAULT_ENV"
    export PROMPT_PY_ENV_NAME
  else
    unset PROMPT_PY_ENV_NAME
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_set_py_name


# Init
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  return 1
fi
