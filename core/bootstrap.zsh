# core/bootstrap.zsh
setopt EXTENDED_GLOB

_ORBIT_DIR=${0:A:h:h}    # path to repo root
source "$_ORBIT_DIR/core/detect_platform.zsh"
source "$_ORBIT_DIR/core/path_helpers.zsh"
source "$_ORBIT_DIR/core/detect_apps.zsh"

# 1) Secrets first
source "$_ORBIT_DIR/core/secrets.zsh"

# 2) Environment (ordered)
for f in $_ORBIT_DIR/modules/env/*.zsh(.N); do source "$f"; done

# 3. Aliases and functions
for f in $_ORBIT_DIR/modules/aliases/*.zsh(.N); do source "$f"; done
for f in $_ORBIT_DIR/modules/functions/*.zsh(.N); do source "$f"; done

# Optional legacy helpers (Cloudflare/Tailscale if present)
[[ -f "$_ORBIT_DIR/modules/functions/external.zsh" ]] && source "$_ORBIT_DIR/modules/functions/external.zsh"

# 4) Completions — lazy init on first prompt
if [[ -o interactive && ${ORBIT_ENABLE_COMPLETIONS:-1} -eq 1 ]]; then
  autoload -Uz add-zsh-hook compinit
  _orbit_load_completions() {
    [[ -d "$_ORBIT_DIR/modules/completions" ]] && fpath=($_ORBIT_DIR/modules/completions $fpath)
    if ! typeset -f _main_complete >/dev/null; then
      mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
    fi
    add-zsh-hook -d precmd _orbit_load_completions
  }
  add-zsh-hook precmd _orbit_load_completions
fi

# 5) Prompt (interactive only)
if [[ -o interactive && -z ${ORBIT_DISABLE_PROMPT:-} ]]; then
  case "${ORBIT_PROMPT:-auto}" in
    starship|auto)
      if source "$_ORBIT_DIR/modules/prompt/starship.zsh" 2>/dev/null; then
        : # starship OK
      elif source "$_ORBIT_DIR/modules/prompt/p10k.zsh" 2>/dev/null; then
        : # p10k fallback OK
      else
        : # no prompt engine available; use default PS1
      fi
      ;;
    p10k)
      if source "$_ORBIT_DIR/modules/prompt/p10k.zsh" 2>/dev/null; then
        : # p10k OK
      elif source "$_ORBIT_DIR/modules/prompt/starship.zsh" 2>/dev/null; then
        : # starship fallback OK
      else
        : # nothing
      fi
      ;;
  esac
fi
