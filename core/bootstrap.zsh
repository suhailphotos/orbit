# core/bootstrap.zsh
setopt EXTENDED_GLOB

_ORBIT_DIR=${0:A:h:h}    # path to repo root
source "$_ORBIT_DIR/core/detect_platform.zsh"
source "$_ORBIT_DIR/core/path_helpers.zsh"

# 1. Secrets – load first so later files can reference them
source "$_ORBIT_DIR/core/secrets.zsh"

# 2. Environment variables (ordered)
for f in $_ORBIT_DIR/modules/env/*.zsh(.N); do source "$f"; done

# 3. Aliases and functions
source "$_ORBIT_DIR/modules/aliases.zsh"
for f in $_ORBIT_DIR/modules/functions/*.zsh(.N); do source "$f"; done

# 4. Completions – defer loading until first prompt
autoload -Uz add-zsh-hook
_orbit_load_completions() {
  [[ -d "$_ORBIT_DIR/modules/completions" ]] && fpath=($_ORBIT_DIR/modules/completions $fpath)
  compinit
  add-zsh-hook -d precmd _orbit_load_completions
}
add-zsh-hook precmd _orbit_load_completions
