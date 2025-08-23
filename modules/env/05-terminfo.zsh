# modules/env/05-terminfo.zsh
# Make custom terminfo (e.g., xterm-ghostty) available to everything.
# Safe to source on both mac & linux.

# If the current $TERM isn't known to terminfo, compile a local entry once.
if command -v infocmp >/dev/null 2>&1; then
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    mkdir -p "$HOME/.terminfo"
    # Try to dump and compile the active TERM (works on Ghostty)
    if infocmp -x "$TERM" >/tmp/ti.src 2>/dev/null; then
      tic -x -o "$HOME/.terminfo" /tmp/ti.src 2>/dev/null || true
      rm -f /tmp/ti.src
    fi
  fi
fi

# Make sure our per-user db is searched first
if [[ -z "${TERMINFO_DIRS:-}" ]]; then
  export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo"
else
  case ":$TERMINFO_DIRS:" in
    *":$HOME/.terminfo:"*) : ;;
    *) export TERMINFO_DIRS="$HOME/.terminfo:$TERMINFO_DIRS" ;;
  esac
fi

unset -v _
