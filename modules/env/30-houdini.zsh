# mac-only: provide a sane default prefs dir if the user hasn't overridden it
[[ $ORBIT_PLATFORM == mac ]] || return

_latest="$(ls -d /Applications/Houdini/Houdini* 2>/dev/null \
            | sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1)"

if [[ -n $_latest && -z "$HOUDINI_USER_PREF_DIR" ]]; then
  export HOUDINI_USER_PREF_DIR="$HOME/Library/Preferences/houdini/${_latest%.*}"
fi
