# core/detect_apps.zsh — silent detection, safe globs

# ---------- Houdini ----------
ORBIT_HAS_HOUDINI=0
ORBIT_HOUDINI_ROOT=""
ORBIT_HOUDINI_VERSION=""

if [[ ${ORBIT_FORCE_NO_HOUDINI:-0} != 1 ]]; then
  if [[ $ORBIT_PLATFORM == mac ]]; then
    # e.g. /Applications/Houdini/Houdini20.5.123/
    _hdirs=(/Applications/Houdini/Houdini*(N/))
    if (( ${#_hdirs} )); then
      _dir="${_hdirs[-1]}"                          # last by name
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="$_dir"
      ORBIT_HOUDINI_VERSION="${${_dir:t}#Houdini}"  # "20.5.123"
    fi
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    # e.g. /opt/hfs20.5.123/
    _hdirs=(/opt/hfs*(N/))
    if (( ${#_hdirs} )); then
      _dir="${_hdirs[-1]}"
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="$_dir"
      ORBIT_HOUDINI_VERSION="${${_dir:t}#hfs}"      # "20.5.123"
    elif (( $+commands[hconfig] )); then
      ORBIT_HAS_HOUDINI=1
      ORBIT_HOUDINI_ROOT="${HFS:-}"
    fi
  fi
fi

export ORBIT_HAS_HOUDINI ORBIT_HOUDINI_ROOT ORBIT_HOUDINI_VERSION

# ---------- Nuke ----------
ORBIT_HAS_NUKE=0
ORBIT_NUKE_DEFAULT=""
ORBIT_NUKE_EDITIONS=(Nuke NukeX NukeStudio)

if [[ ${ORBIT_FORCE_NO_NUKE:-0} != 1 ]]; then
  if [[ $ORBIT_PLATFORM == mac ]]; then
    # Top-level version folders, e.g. /Applications/Nuke15.0v4/
    _ndirs=(/Applications/Nuke*(N/))
    if (( ${#_ndirs} )); then
      _ndir="${_ndirs[-1]}"
      ORBIT_HAS_NUKE=1
      ORBIT_NUKE_DEFAULT="${_ndir:t}"               # "Nuke15.0v4"
    else
      # Fallback to app bundles if version folder isn’t present
      _apps=(/Applications/Nuke*.app(N) /Applications/NukeX*.app(N) /Applications/NukeStudio*.app(N))
      if (( ${#_apps} )); then
        _app="${_apps[-1]}"
        ORBIT_HAS_NUKE=1
        ORBIT_NUKE_DEFAULT="${_app:t:r}"            # drop .app
      fi
    fi
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    _ndirs=(/usr/local/Nuke*(N/) /opt/Nuke*(N/))
    if (( ${#_ndirs} )); then
      _ndir="${_ndirs[-1]}"
      ORBIT_HAS_NUKE=1
      ORBIT_NUKE_DEFAULT="${_ndir:t}"               # "Nuke15.0v4"
    elif (( $+commands[Nuke] )); then
      ORBIT_HAS_NUKE=1
      ORBIT_NUKE_DEFAULT="Nuke"                      # generic launcher
    fi
  fi
fi

export ORBIT_HAS_NUKE ORBIT_NUKE_DEFAULT ORBIT_NUKE_EDITIONS
