# core/bootstrap.zsh
setopt EXTENDED_GLOB

# keep $path unique; use the array form
typeset -U path

# baseline system dirs first (mac paths first, harmless on linux)
path=(/opt/homebrew/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin $path)

# repo root + export
_ORBIT_DIR=${0:A:h:h}
export ORBIT_HOME="$_ORBIT_DIR"

# ── Optional profiling (opt-in via ORBIT_PROFILE=1) ──────────────────────────
if [[ ${ORBIT_PROFILE:-0} -eq 1 ]]; then
  source "$_ORBIT_DIR/core/profile.zsh"
  orbit_mark "bootstrap:start"
fi

# Core detection + helpers
source "$_ORBIT_DIR/core/detect_platform.zsh"
source "$_ORBIT_DIR/core/path_helpers.zsh"
source "$_ORBIT_DIR/core/detect_apps.zsh"

# Secrets early (env + lazy op:// resolution scaffolding)
source "$_ORBIT_DIR/core/secrets.zsh"

[[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "core:done"

# 2) Environment modules (ordered)
[[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "env:start"
for f in $_ORBIT_DIR/modules/env/*.zsh(.N); do source "$f"; done
[[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "env:done"

# 3) Aliases + functions
[[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "funcs:start"
for f in $_ORBIT_DIR/modules/aliases/*.zsh(.N);   do source "$f"; done
for f in $_ORBIT_DIR/modules/functions/*.zsh(.N); do source "$f"; done
# Optional legacy helpers
[[ -f "$_ORBIT_DIR/modules/functions/external.zsh" ]] && source "$_ORBIT_DIR/modules/functions/external.zsh"
[[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "funcs:done"

# 4) Completions — lazy init on first prompt (interactive only)
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
  [[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "prompt:start"
  case "${ORBIT_PROMPT:-auto}" in
    starship|auto)
      if source "$_ORBIT_DIR/modules/prompt/starship.zsh" 2>/dev/null; then
        : # starship OK
      elif source "$_ORBIT_DIR/modules/prompt/p10k.zsh" 2>/dev/null; then
        : # p10k fallback OK
      fi
      ;;
    p10k)
      if source "$_ORBIT_DIR/modules/prompt/p10k.zsh" 2>/dev/null; then
        : # p10k OK
      elif source "$_ORBIT_DIR/modules/prompt/starship.zsh" 2>/dev/null; then
        : # starship fallback OK
      fi
      ;;
  esac
  [[ ${ORBIT_PROFILE:-0} -eq 1 ]] && orbit_mark "prompt:done"
fi

# ── Profiling summary (very end) ─────────────────────────────────────────────
if [[ ${ORBIT_PROFILE:-0} -eq 1 ]]; then
  orbit_mark "bootstrap:end"
  _orbit_profile_done
fi
