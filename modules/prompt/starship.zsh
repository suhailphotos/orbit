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

# Derive a clean poetry venv name once per prompt (no processes)
_prompt_set_py_name() {
  if [[ -n $VIRTUAL_ENV ]]; then
    local base="${VIRTUAL_ENV:t}"     # basename of venv path
    PROMPT_PY_ENV_NAME="${base%-py*}" # strip trailing "-py3.11" etc.
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
