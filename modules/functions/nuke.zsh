# modules/functions/nuke.zsh
# mac-only; no-op elsewhere
[[ $ORBIT_PLATFORM == mac ]] || {
  nukeUtils() { echo "nukeUtils: macOS only."; }
  return
}

nukeUtils() {
  local root="$DROPBOX/matrix/packages/nukeUtils"
  local nuke_version="${NUKE_VERSION:-15.0v4}"   # override via env if needed
  local cmd="$1"; shift

  _nuke_activate() {
    [[ "$PWD" == "$root" ]] || cd "$root" || return 1
    [[ -n $VIRTUAL_ENV ]] || source "$(poetry env info --path)/bin/activate"
  }

  _nuke_prefs_and_paths() {
    export NUKE_USER_DIR="$HOME/.nuke"
    mkdir -p "$NUKE_USER_DIR"
    local plugins="$root/plugins"
    [[ -d "$plugins" ]] && export NUKE_PATH="$plugins:${NUKE_PATH}"
  }

  _nuke_launch() {
    open -a "Nuke${nuke_version}" || echo "Could not find Nuke ${nuke_version} app bundle."
  }

  case "$cmd" in
    -e)
      _nuke_activate || return 1
      _nuke_prefs_and_paths
      echo "Nuke environment ready (Poetry venv + NUKE_PATH)."
      ;;
    launch)
      _nuke_activate || true
      _nuke_prefs_and_paths
      _nuke_launch
      ;;
    *)
      _nuke_activate
      echo "In nukeUtils env. Use 'nukeUtils -e' or 'nukeUtils launch'."
      ;;
  esac
}
