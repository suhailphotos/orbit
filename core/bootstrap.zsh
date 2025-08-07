# core/bootstrap.zsh
setopt EXTENDED_GLOB

_ORBIT_DIR=${0:A:h:h}    # path to repo root
source "$_ORBIT_DIR/core/detect_platform.zsh"
source "$_ORBIT_DIR/core/path_helpers.zsh"

# 1) Secrets first
source "$_ORBIT_DIR/core/secrets.zsh"

# 2) Environment (ordered)
for f in $_ORBIT_DIR/modules/env/*.zsh(.N); do source "$f"; done

# 3) Aliases & functions
source "$_ORBIT_DIR/modules/aliases.zsh"
for f in $_ORBIT_DIR/modules/functions/*.zsh(.N); do source "$f"; done

# Optional legacy helpers (Cloudflare/Tailscale if present)
[[ -f "$_ORBIT_DIR/modules/functions/external.zsh" ]] && source "$_ORBIT_DIR/modules/functions/external.zsh"

# 4) Completions — lazy init on first prompt
autoload -Uz add-zsh-hook
_orbit_load_completions() {
  [[ -d "$_ORBIT_DIR/modules/completions" ]] && fpath=($_ORBIT_DIR/modules/completions $fpath)
  compinit
  add-zsh-hook -d precmd _orbit_load_completions
}
add-zsh-hook precmd _orbit_load_completions
