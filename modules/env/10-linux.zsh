# modules/env/10-linux.zsh
[[ $ORBIT_PLATFORM == linux ]] || return

# --- Locale: prefer UTF-8 if not set (harmless if already configured) ---
if [[ -o interactive && -z ${ORBIT_LOCALE_CHECKED-} ]]; then
  export ORBIT_LOCALE_CHECKED=1

  # Choose a UTF-8 locale we actually have:
  # Prefer C.UTF-8 (shipped by default), otherwise use en_US.UTF-8 if generated.
  local _utf8="C.UTF-8"
  if locale -a 2>/dev/null | grep -qi '^en_US\.utf-8$'; then
    _utf8="en_US.UTF-8"
  fi

  # If either var isn't UTF-8, set it. (LC_CTYPE is the important one for widths.)
  [[ ${LC_CTYPE-} == *UTF-8* ]] || export LC_CTYPE="$_utf8"
  [[ ${LANG-}     == *UTF-8* ]] || export LANG="$_utf8"
  unset _utf8
fi

# --- TERM safety: if this host doesn't know our TERM, downgrade once ---
# Only do this for interactive shells to avoid affecting scripts/cron.
if [[ -o interactive ]]; then
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    # Common on fresh hosts before xterm-ghostty terminfo is copied over.
    export TERM=xterm-256color
  fi
fi

# Nothing else here; prompt/eza/etc are handled by other modules.
