# modules/env/30-houdini.zsh
[[ "${ORBIT_HAS_HOUDINI:-0}" == 1 ]] || return
[[ $ORBIT_PLATFORM == mac || $ORBIT_PLATFORM == linux ]] || return

# Prefer detect_apps result; else probe
_ver="${ORBIT_HOUDINI_VERSION:-$(_latest="$(ls -1d /Applications/Houdini/Houdini* 2>/dev/null | sed 's|.*/Houdini||' | sort -r | head -n1)"; print -r -- "$_latest")}"

if [[ -n $_ver ]]; then
  # X.Y from X.Y.Z
  _mm="${_ver%.*}"
  if [[ $ORBIT_PLATFORM == mac ]]; then
    export ORBIT_HOUDINI_PREF_DEFAULT="$HOME/Library/Preferences/houdini/$_mm"
  else
    export ORBIT_HOUDINI_PREF_DEFAULT="$HOME/houdini$_mm"
  fi
fi
unset _ver _mm _latest
