# modules/functions/nuke.zsh

# If Nuke isn't installed, define a harmless stub and exit quietly
if [[ "${ORBIT_HAS_NUKE:-0}" != 1 ]]; then
  nukeUtils() {
    echo "Nuke not available on this machine."
    return 1
  }
  return
fi

# mac-only helpers for now; stub elsewhere
if [[ $ORBIT_PLATFORM != mac ]]; then
  nukeUtils() {
    echo "nukeUtils: macOS only in this repo."
    return 1
  }
  return
fi

nukeUtils() {
  local root="$DROPBOX/matrix/packages/nukeUtils"
  local edition="${NUKE_EDITION:-Nuke}"              # Nuke | NukeX | NukeStudio
  local nuke_version="${NUKE_VERSION:-$ORBIT_NUKE_DEFAULT}"  # e.g., Nuke15.0v4
  local cmd="$1"; shift

  _nuke_activate() {
    [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
    [[ "$PWD" == "$root" ]] || cd "$root" || return 1
    if command -v poetry >/dev/null 2>&1; then
      [[ -n $VIRTUAL_ENV ]] || source "$(poetry env info --path)/bin/activate"
    fi
  }

  _nuke_prefs_and_paths() {
    export NUKE_USER_DIR="${NUKE_USER_DIR:-$HOME/.nuke}"
    mkdir -p "$NUKE_USER_DIR"
    local plugins="$root/plugins"
    [[ -d "$plugins" ]] && export NUKE_PATH="$plugins:${NUKE_PATH}"
  }

  _nuke_launch_mac() {
    local appname="${edition}${nuke_version}"   # e.g., "NukeX15.0v4"
    # If NUKE_VERSION looked generic ("Nuke"), fall back to edition only
    if [[ -z "$nuke_version" || "$nuke_version" == "Nuke" ]]; then
      appname="${edition}"
    fi
    open -a "$appname" || echo "Could not find app: $appname"
  }

  case "$cmd" in
    -e)
      _nuke_activate || return 1
      _nuke_prefs_and_paths
      echo "Nuke environment ready (venv + NUKE_PATH)."
      ;;
    launch)
      _nuke_activate || true
      _nuke_prefs_and_paths
      _nuke_launch_mac
      ;;
    *)
      _nuke_activate
      echo "In nukeUtils env. Use 'nukeUtils -e' or 'nukeUtils launch'."
      ;;
  esac
}
