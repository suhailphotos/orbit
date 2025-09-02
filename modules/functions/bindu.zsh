# modules/functions/bindu.zsh
# Toggleable, low-overhead autosync for ~/.config (bindu).
# When enabled, sync runs at most every $BINDU_FETCH_INTERVAL seconds.
# Starship indicator is updated only when a sync happens (or on-demand).

# ---- settings ---------------------------------------------------------------
: ${BINDU_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}}      # bindu repo
: ${BINDU_REMOTE:=origin}
: ${BINDU_FETCH_INTERVAL:=600}                         # seconds
: ${BINDU_AUTO_FF_PULL:=1}                             # 1 = ff-only pull when clean
: ${BINDU_AUTOSYNC:=0}                                 # 1 = enable autosync hooks
: ${BINDU_LOG:="$ORBIT_HOME/.cache/bindu.log"}
: ${BINDU_STAMP:="$ORBIT_HOME/.cache/bindu.fetch.stamp"}

mkdir -p "${BINDU_LOG:h}" 2>/dev/null || true

# ---- one-time detection & cached state -------------------------------------
if git -C "$BINDU_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  typeset -g BINDU_IS_REPO=1
else
  typeset -g BINDU_IS_REPO=0
fi

# cache "last sync" in memory (load once from stamp if present)
typeset -g -i BINDU_LAST_SYNC=0
[[ -r "$BINDU_STAMP" ]] && read -r BINDU_LAST_SYNC < "$BINDU_STAMP" || true
(( ${+EPOCHSECONDS} )) || { zmodload -F zsh/datetime 2>/dev/null || true; }

# ---- mark helpers -----------------------------------------------------------
_bindu_clear_mark() {
  unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED
}

_bindu_compute_mark() {
  (( BINDU_IS_REPO )) || { _bindu_clear_mark; return; }

  local upstream head remote base
  upstream=$(git -C "$BINDU_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || upstream=""
  [[ -z $upstream ]] && { _bindu_clear_mark; return; }

  head=$(git -C "$BINDU_DIR" rev-parse @ 2>/dev/null)         || return
  remote=$(git -C "$BINDU_DIR" rev-parse "@{u}" 2>/dev/null)  || return
  base=$(git -C "$BINDU_DIR" merge-base @ "@{u}" 2>/dev/null) || return

  _bindu_clear_mark
  if [[ $head == $remote ]]; then
    return
  elif [[ $head == $base && $remote != $base ]]; then
    export STARSHIP_BINDU_BEHIND="⇣"
  elif [[ $remote == $base && $head != $base ]]; then
    export STARSHIP_BINDU_AHEAD="⇡"
  else
    export STARSHIP_BINDU_DIVERGED="⇕"
    printf '%s [%s] diverged: local=%s remote=%s base=%s\n' \
      "$(date)" "$BINDU_DIR" "$head" "$remote" "$base" >>"$BINDU_LOG"
  fi
}

# ---- syncing ---------------------------------------------------------------
_bindu_sync_and_mark() {
  emulate -L zsh
  setopt localoptions

  (( BINDU_IS_REPO )) || { _bindu_clear_mark; return; }

  # fetch quietly (offline is fine)
  git -C "$BINDU_DIR" fetch --tags --quiet "$BINDU_REMOTE" >/dev/null 2>>"$BINDU_LOG" || true

  # optional fast-forward pull when behind and clean
  if (( BINDU_AUTO_FF_PULL )); then
    if git -C "$BINDU_DIR" merge-base --is-ancestor @ "@{u}" 2>/dev/null; then
      if git -C "$BINDU_DIR" diff --quiet && git -C "$BINDU_DIR" diff --cached --quiet; then
        git -C "$BINDU_DIR" pull --ff-only --quiet >/dev/null 2>>"$BINDU_LOG" || \
          printf '%s ff-pull failed in %s\n' "$(date)" "$BINDU_DIR" >>"$BINDU_LOG"
      else
        printf '%s skipped ff-pull (dirty) in %s\n' "$(date)" "$BINDU_DIR" >>"$BINDU_LOG"
      fi
    fi
  fi

  _bindu_compute_mark
  BINDU_LAST_SYNC=${EPOCHSECONDS:-$(printf "%(%s)T" -1)}
  printf '%s\n' "$BINDU_LAST_SYNC" >| "$BINDU_STAMP" 2>/dev/null || true
}

# ---- prompt hook (very cheap) ----------------------------------------------
# Only checks the integer timer; does no git unless interval elapsed.
_bindu_precmd() {
  (( BINDU_AUTOSYNC )) || return
  (( BINDU_IS_REPO )) || return
  local now=${EPOCHSECONDS:-$(printf "%(%s)T" -1)}
  (( now - BINDU_LAST_SYNC < BINDU_FETCH_INTERVAL )) && return
  _bindu_sync_and_mark
}

# ---- toggle & utility commands ---------------------------------------------
bindu_autosync_on()  { BINDU_AUTOSYNC=1; _bindu_hook_enable;  echo "bindu autosync: ON (interval ${BINDU_FETCH_INTERVAL}s)"; }
bindu_autosync_off() { BINDU_AUTOSYNC=0; _bindu_hook_disable; echo "bindu autosync: OFF"; }
bindu_autosync_status() {
  echo "autosync=${BINDU_AUTOSYNC} interval=${BINDU_FETCH_INTERVAL}s last_sync=${BINDU_LAST_SYNC}"
  [[ -r "$BINDU_LOG" ]] && tail -n3 "$BINDU_LOG" 2>/dev/null || true
}
bindu_sync_now()     { _bindu_sync_and_mark; echo "bindu: synced."; }
bindu_mark_refresh() { _bindu_compute_mark; echo "bindu: mark refreshed."; }

# ---- hook management --------------------------------------------------------
autoload -Uz add-zsh-hook
typeset -g BINDU_HOOK_ACTIVE=0
_bindu_hook_enable() {
  (( BINDU_HOOK_ACTIVE )) && return
  add-zsh-hook precmd _bindu_precmd
  BINDU_HOOK_ACTIVE=1
}
_bindu_hook_disable() {
  (( ! BINDU_HOOK_ACTIVE )) && return
  add-zsh-hook -d precmd _bindu_precmd 2>/dev/null || true
  BINDU_HOOK_ACTIVE=0
}

# enable hook if user opted in
(( BINDU_AUTOSYNC )) && _bindu_hook_enable
