# modules/functions/terminfo.zsh
# Push current TERM’s entry to a remote host: push_terminfo user@host [TERM]
push_terminfo() {
  local host="${1:-}"; shift || true
  local term="${1:-$TERM}"
  if [[ -z "$host" ]]; then
    echo "Usage: push_terminfo user@host [TERM]" >&2
    return 1
  fi
  if ! infocmp -x "$term" >/dev/null 2>&1; then
    echo "Local system doesn’t know term '$term'." >&2
    return 1
  fi
  infocmp -x "$term" | ssh "$host" 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin'
}

# Quick check on a host: terminfo_ok user@host [TERM]
terminfo_ok() {
  local host="${1:-}"; shift || true
  local term="${1:-$TERM}"
  [[ -z "$host" ]] && { echo "Usage: terminfo_ok user@host [TERM]"; return 1; }
  ssh "$host" "infocmp -x $term >/dev/null 2>&1 && echo '$term: OK' || echo '$term: MISSING'"
}
