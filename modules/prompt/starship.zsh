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

# Init
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  return 1
fi
