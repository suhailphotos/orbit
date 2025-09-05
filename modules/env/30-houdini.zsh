# Only run if Houdini is installed
[[ "${ORBIT_HAS_HOUDINI:-0}" == 1 ]] || return

# mac-only prefs default
[[ $ORBIT_PLATFORM == mac ]] || return

# Use detected version if we have it; otherwise probe (quietly)
_ver="$ORBIT_HOUDINI_VERSION"
if [[ -z $_ver ]]; then
  _latest="$(ls -1d /Applications/Houdini/Houdini* 2>/dev/null | sed 's|.*/Houdini||' | sort -r | head -n1)"
  _ver="$_latest"
fi

# Expose a helper var I can use elsewhere.
if [[ -n $_ver ]]; then
  export ORBIT_HOUDINI_PREF_DEFAULT="$HOME/Library/Preferences/houdini/${_ver%.*}"
fi
