# modules/env/10-linux.zsh
[[ $ORBIT_PLATFORM == linux ]] || return

# --- TERM safety: if this host doesn't know our TERM, downgrade once ---
# Only do this for interactive shells to avoid affecting scripts/cron.
if [[ -o interactive ]]; then
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    # Common on fresh hosts before xterm-ghostty terminfo is copied over.
    export TERM=xterm-256color
  fi
fi

# Nothing else here; prompt/eza/etc are handled by other modules.
