# modules/functions/bindu.zsh
# Auto-fetch ~/.config (bindu) quietly and expose a tiny Starship indicator.

# ---- settings (override per-host in env files if you like) -------------------
: ${BINDU_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}}     # path to bindu repo
: ${BINDU_REMOTE:=origin}                             # remote name
: ${BINDU_FETCH_INTERVAL:=600}                        # seconds between fetches
: ${BINDU_LOG:="$ORBIT_HOME/.cache/bindu.log"}        # log file
: ${BINDU_STAMP:="$ORBIT_HOME/.cache/bindu.fetch.stamp"}  # last-fetch stamp

# ensure cache dir
mkdir -p "${BINDU_LOG:h}" 2>/dev/null || true

_bindu_is_repo() {
  git -C "$BINDU_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# background fetch, at most every BINDU_FETCH_INTERVAL seconds
_bindu_autofetch_maybe() {
  [[ -o interactive ]] || return
  _bindu_is_repo || { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  local now last=0
  now="$(printf %(%s)T -1)"      # zsh builtin (no external date)
  [[ -f "$BINDU_STAMP" ]] && read -r last < "$BINDU_STAMP" || true
  (( now - last < BINDU_FETCH_INTERVAL )) && return

  (
    # never touch the TTY; fail silently; record errors to log
    git -C "$BINDU_DIR" fetch --tags --quiet "$BINDU_REMOTE" >/dev/null 2>>"$BINDU_LOG" || true
    printf '%s\n' "$now" >| "$BINDU_STAMP" || true
  ) &!   # background, disowned
}

# compute relation to upstream and set one of three Starship env vars
_bindu_set_starship_mark() {
  _bindu_is_repo || { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  # discover upstream (fast path). If none, show nothing.
  local upstream
  upstream=$(git -C "$BINDU_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || upstream=""
  [[ -z $upstream ]] && { unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED; return; }

  local head remote base
  head=$(git -C "$BINDU_DIR" rev-parse @ 2>/dev/null)         || return
  remote=$(git -C "$BINDU_DIR" rev-parse "@{u}" 2>/dev/null)  || return
  base=$(git -C "$BINDU_DIR" merge-base @ "@{u}" 2>/dev/null) || return

  # clear all, then set exactly one
  unset STARSHIP_BINDU_AHEAD STARSHIP_BINDU_BEHIND STARSHIP_BINDU_DIVERGED

  if [[ $head == $remote ]]; then
    return                        # in sync → no indicator
  elif [[ $head == $base && $remote != $base ]]; then
    export STARSHIP_BINDU_BEHIND="⇣"   # need to pull (fast-forwardable)
  elif [[ $remote == $base && $head != $base ]]; then
    export STARSHIP_BINDU_AHEAD="⇡"    # local ahead (need to push)
  else
    export STARSHIP_BINDU_DIVERGED="⇕" # conflict/force required
    printf '%s [%s] diverged: local=%s remote=%s base=%s\n' \
      "$(date)" "$BINDU_DIR" "$head" "$remote" "$base" >>"$BINDU_LOG"
  fi
}

# handy helpers you can call manually, all silent if offline
bindu_status() {
  _bindu_is_repo || { echo "bindu: $BINDU_DIR is not a git repo."; return 1; }
  git -C "$BINDU_DIR" status -sb --porcelain=2
}
bindu_fetch_now() {
  _bindu_is_repo || return 0
  git -C "$BINDU_DIR" fetch --tags --quiet "$BINDU_REMOTE" >/dev/null 2>>"$BINDU_LOG" || true
  printf '%s\n' "$(printf %(%s)T -1)" >| "$BINDU_STAMP" || true
}
bindu_sync_ff() {
  _bindu_is_repo || return 0
  # only fast-forward if clean and behind; otherwise do nothing
  git -C "$BINDU_DIR" diff --quiet && git -C "$BINDU_DIR" diff --cached --quiet || { echo "bindu: uncommitted changes, not pulling."; return 1; }
  if git -C "$BINDU_DIR" merge-base --is-ancestor @ "@{u}" 2>/dev/null; then
    echo "bindu: fast-forwarding to upstream..."
    git -C "$BINDU_DIR" pull --ff-only >/dev/null 2>>"$BINDU_LOG" || true
  fi
}

# wire into the prompt lifecycle (very light)
autoload -Uz add-zsh-hook
add-zsh-hook precmd _bindu_set_starship_mark
add-zsh-hook precmd _bindu_autofetch_maybe
