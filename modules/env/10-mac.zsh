[[ $ORBIT_PLATFORM == mac ]] || return

export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
export DOCKER="$DROPBOX/matrix/docker"

# Houdini prefs (replaces that dynamic ls … bit)
_latest="$(ls -d /Applications/Houdini/Houdini* 2>/dev/null \
            | sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1)"
export HOUDINI_USER_PREF_DIR="$HOME/Library/Preferences/houdini/${_latest%.*}"
