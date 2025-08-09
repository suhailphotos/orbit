# App presence flags for the rest of Orbit to use
# Requires ORBIT_PLATFORM (set in detect_platform.zsh)

# --- Houdini ---
ORBIT_HAS_HOUDINI=0
ORBIT_HOUDINI_ROOT=""
ORBIT_HOUDINI_VERSION=""

if [[ ${ORBIT_FORCE_NO_HOUDINI:-0} == 1 ]]; then
  :  # forced off
else
  if [[ $ORBIT_PLATFORM == mac ]]; then
    # Example: /Applications/Houdini/Houdini20.5.123
    _dir="$(ls -1d /Applications/Houdini/Houdini* 2>/dev/null | sort -r | head -n1)"
    if [[ -n $_dir ]]; then
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="$_dir"
      ORBIT_HOUDINI_VERSION="${_dir:t#Houdini}"  # "20.5.123"
    fi
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    # Example: /opt/hfs20.5.123
    _dir="$(ls -1d /opt/hfs* 2>/dev/null | sort -r | head -n1)"
    if [[ -n $_dir ]]; then
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="$_dir"
      ORBIT_HOUDINI_VERSION="${_dir:t#hfs}"      # "20.5.123"
    elif command -v hconfig >/dev/null 2>&1; then
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="${HFS:-}"
    fi
  fi
fi

export ORBIT_HAS_HOUDINI ORBIT_HOUDINI_ROOT ORBIT_HOUDINI_VERSION

# --- Nuke ---
ORBIT_HAS_NUKE=0
ORBIT_NUKE_DEFAULT=""
ORBIT_NUKE_EDITIONS=("Nuke" "NukeX" "NukeStudio")  # mac app names

if [[ ${ORBIT_FORCE_NO_NUKE:-0} == 1 ]]; then
  :  # forced off
else
  if [[ $ORBIT_PLATFORM == mac ]]; then
    # Typical mac layout: /Applications/Nuke15.0v4/Nuke15.0v4.app (and also NukeX…, NukeStudio…)
    _nuke_dirs=($(ls -1d /Applications/Nuke*[0-9]* 2>/dev/null | sort -Vr))
    if (( ${#_nuke_dirs[@]} )); then
      ORBIT_HAS_NUKE=1
      # Pick newest folder name as default version (e.g., "Nuke15.0v4")
      ORBIT_NUKE_DEFAULT="${_nuke_dirs[1]:t}"  # folder basename
      # Sanity: strip any trailing slashes
      ORBIT_NUKE_DEFAULT="${ORBIT_NUKE_DEFAULT%/}"
    else
      # Fallback: look for app bundles directly (less reliable)
      for ed in "${ORBIT_NUKE_EDITIONS[@]}"; do
        _app="$(ls -1d /Applications/${ed}[0-9]*.app 2>/dev/null | sort -Vr | head -n1)"
        if [[ -n $_app ]]; then
          ORBIT_HAS_NUKE=1
          ORBIT_NUKE_DEFAULT="${_app:t:r}"   # app name without .app
          break
        fi
      done
    fi

  elif [[ $ORBIT_PLATFORM == linux ]]; then
    # Common linux installs:
    #   /usr/local/Nuke15.0v4/Nuke15.0v4
    #   /opt/Nuke15.0v4/Nuke15.0v4
    _nuke_dirs=($(ls -1d /usr/local/Nuke*[0-9]* /opt/Nuke*[0-9]* 2>/dev/null | sort -Vr))
    if (( ${#_nuke_dirs[@]} )); then
      ORBIT_HAS_NUKE=1
      ORBIT_NUKE_DEFAULT="${_nuke_dirs[1]:t}"  # e.g., "Nuke15.0v4"
    else
      # Last resort: see if a generic "Nuke" launcher exists
      if command -v Nuke >/dev/null 2>&1; then
        ORBIT_HAS_NUKE=1
        ORBIT_NUKE_DEFAULT="Nuke"  # generic; version unknown
      fi
    fi
  fi
fi

export ORBIT_HAS_NUKE ORBIT_NUKE_DEFAULT ORBIT_NUKE_EDITIONS
