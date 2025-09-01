# modules/functions/bindu.zsh
# Auto-sync ~/.config (bindu) quietly. Show a tiny Starship indicator if action needed.

# ---- settings ---------------------------------------------------------------
: ${BINDU_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}}     # path to bindu repo
: ${BINDU_REMOTE:=origin}                             # remote name
: ${BINDU_FETCH_INTERVAL:=600}                        # seconds between syncs
: ${BINDU_AUTO_FF_PULL:=1}                            # 1 = auto fast-forward pull when clean
: ${BINDU_LOG:="$ORBIT_HOME/.cache/bindu.log"}        # log file
: ${BINDU_STAMP:="$ORBIT_HOME/.cache/bindu.fetch.stamp"}  # last-sync stamp

mkdir -p "${BINDU_LOG:h}" 2>/dev/null || true

_bindu_is_repo() {
  git -C "$BINDU_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

_bindu_now() {
  # epoch seconds without forking if possible
  if (( ${+EPOCHSECONDS} )); then
    print -r -- $EPOCHSECONDS
  else
    zmodload -F zsh/datetime 2>/dev/null || true
    if (( ${+EPOCHSECONDS} )); then
      print -r -- $EPOCHSECONDS
    else
      printf "%(%s)T" -1
    fi
  fi
}

_bindu_repo_clean() {
  git -C "$BINDU_DIR" diff --quiet && git -C "$BINDU_DIR" diff --cached --quiet
}

_bindu_upstream() {
  git -C "$BINDU_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null
}

_bindu_sync_once() {
  emulate -L zsh
  setopt localoptions

  [[ -o interactive ]] || return
  _bindu_is_repo || { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  # throttle
  local now last=0
  now="$(_bindu_now)"
  [[ -f "$BINDU_STAMP" ]] && read -r last < "$BINDU_STAMP" || true
  (( now - last < BINDU_FETCH_INTERVAL )) || {
    # fetch quietly; if offline, just log and continue
    git -C "$BINDU_DIR" fetch --tags --quiet "$BINDU_REMOTE" >/dev/null 2>>"$BINDU_LOG" || true
    printf '%s\n' "$now" >| "$BINDU_STAMP" 2>/dev/null || true
  }

  # try to fast-forward if safe and requested
  if (( BINDU_AUTO_FF_PULL )); then
    local upstream head remote base
    upstream="$(_bindu_upstream)" || upstream=""
    if [[ -n $upstream ]]; then
      head=$(git -C "$BINDU_DIR" rev-parse @ 2>/dev/null)         || return
      remote=$(git -C "$BINDU_DIR" rev-parse "@{u}" 2>/dev/null)  || return
      base=$(git -C "$BINDU_DIR" merge-base @ "@{u}" 2>/dev/null) || return

      # behind & fast-forwardable if local is ancestor of upstream
      if [[ $head != $remote ]] && git -C "$BINDU_DIR" merge-base --is-ancestor @ "@{u}" 2>/dev/null; then
        if _bindu_repo_clean; then
          # do the ff-only pull silently
          git -C "$BINDU_DIR" pull --ff-only --quiet >/dev/null 2>>"$BINDU_LOG" || {
            printf '%s ff-pull failed in %s\n' "$(date)" "$BINDU_DIR" >>"$BINDU_LOG"
          }
        else
          # repo dirty; log but don’t touch
          printf '%s skipped ff-pull (dirty working tree) in %s\n' "$(date)" "$BINDU_DIR" >>"$BINDU_LOG"
        fi
      fi
    fi
  fi
}

_bindu_set_starship_mark() {
  emulate -L zsh
  setopt localoptions

  _bindu_is_repo || { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  local upstream head remote base
  upstream="$(_bindu_upstream)" || upstream=""
  [[ -z $upstream ]] && { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  head=$(git -C "$BINDU_DIR" rev-parse @ 2>/dev/null)         || return
  remote=$(git -C "$BINDU_DIR" rev-parse "@{u}" 2>/dev/null)  || return
  base=$(git -C "$BINDU_DIR" merge-base @ "@{u}" 2>/dev/null) || return

  unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED

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

# manual helpers
bindu_status()   { _bindu_is_repo && git -C "$BINDU_DIR" status -sb --porcelain=2; }
bindu_fetch_now(){ _bindu_is_repo && git -C "$BINDU_DIR" fetch --tags --quiet "$BINDU_REMOTE" >/dev/null 2>>"$BINDU_LOG" || true; printf '%s\n' "$(_bindu_now)" >| "$BINDU_STAMP" 2>/dev/null || true; }
bindu_sync_ff()  {
  _bindu_is_repo || return 0
  if _bindu_repo_clean && git -C "$BINDU_DIR" merge-base --is-ancestor @ "@{u}" 2>/dev/null; then
    git -C "$BINDU_DIR" pull --ff-only --quiet >/dev/null 2>>"$BINDU_LOG" || true
  else
    echo "bindu: cannot fast-forward (dirty or not behind)."
    return 1
  fi
}
bindu_autosync_now(){ BINDU_FETCH_INTERVAL=0 _bindu_sync_once; _bindu_set_starship_mark; }

# Hooks: run sync first, then compute mark for this prompt
autoload -Uz add-zsh-hook
add-zsh-hook precmd _bindu_sync_once
add-zsh-hook precmd _bindu_set_starship_mark
