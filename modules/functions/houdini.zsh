# modules/functions/houdini.zsh
# If Houdini isn't installed, define stubs and exit quietly
if [[ "${ORBIT_HAS_HOUDINI:-0}" != 1 ]]; then
  houdiniUtils() { return 1; }   # silent
  return
fi

# mac-only Houdini utilities; no-op on other platforms
[[ $ORBIT_PLATFORM == mac ]] || {
  houdiniUtils() { echo "houdiniUtils: macOS only."; }
  return
}

houdini_utils_path() {
  echo "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils"
}

houdini_version() {
  if [[ -n "$1" ]]; then
    echo "$1"
  else
    ls -d /Applications/Houdini/Houdini* 2>/dev/null | \
      sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1
  fi
}

# Your preferred mac location for prefs (Dropbox/appSettings)
houdini_set_user_pref() {
  local version="${1:-$(houdini_version)}"
  export HOUDINI_USER_PREF_DIR="$HOME/Library/CloudStorage/Dropbox/appSettings/houdini/mac/${version%.*}"
}

houdini_activate_env() {
  local env_dir="$(houdini_utils_path)"
  cd "$env_dir" || return 1
  [[ -n $VIRTUAL_ENV ]] || source "$(poetry env info --path)/bin/activate"
}

houdini_bootstrap_hfs_env() {
  local ver="${1:-$(houdini_version)}"
  local RES="/Applications/Houdini/Houdini${ver}/Frameworks/Houdini.framework/Versions/Current/Resources"
  [[ -d $RES ]] || { echo "Houdini resources not found: $RES"; return 1; }
  export PYTHONPATH="$RES/houdini/python3.11libs:${PYTHONPATH}"
  export DYLD_INSERT_LIBRARIES="$RES/Houdini"
  source "$RES/houdini_setup" || return 1
}

houdini_patch_env() {
  local project="${1:-houdiniUtils}"
  local ver="${2:-$(houdini_version)}"
  houdini_set_user_pref "$ver"
  local env_dir="$DROPBOX/matrix/packages/$project"
  cd "$env_dir" || return 1
  local ppath="$(poetry env info --path 2>/dev/null)"
  [[ -n $ppath ]] || { echo "Poetry env not found for $project"; return 1; }
  local site="$ppath/lib/python3.11/site-packages"
  local f="$HOUDINI_USER_PREF_DIR/houdini.env"
  mkdir -p "$HOUDINI_USER_PREF_DIR"
  touch "$f"
  grep -q "$site" "$f" || {
    echo "PYTHONPATH=\"\$PYTHONPATH:$site\"" >> "$f"
    echo "Added $site to $f"
  }
}

houdini_open_vscode() {
  local file="$1"
  [[ -z "$file" ]] && { echo "No file specified"; return 1; }
  open -a "Visual Studio Code" "$file"
  sleep 1
}

# Compatibility with legacy:
#   houdiniUtils                → prefs + Poetry venv
#   houdiniUtils -e [20.5.584]  → + HFS env bootstrap
#   houdiniUtils -hou           → same as -e, then run importhou if present
#   houdiniUtils patchenv       → write site-packages into houdini.env
#   houdiniUtils vscode <file>  → open file in VS Code
houdiniUtils() {
  local arg1="$1"; shift
  case "$arg1" in
    patchenv)
      houdini_patch_env "${1:-houdiniUtils}" "${2:-$(houdini_version)}"
      ;;
    vscode)
      houdini_open_vscode "$1"
      ;;
    -e|-hou)
      local ver="$(houdini_version "${1:-}")"
      houdini_set_user_pref "$ver"
      houdini_activate_env || return 1
      houdini_bootstrap_hfs_env "$ver" || return 1
      if [[ "$arg1" == "-hou" ]]; then
        local script="$PWD/houdiniutils/importhou/importhou.py"
        [[ -f $script ]] && python3 "$script"
      else
        echo "Houdini env bootstrapped for $ver"
      fi
      ;;
    *)
      houdini_set_user_pref "$(houdini_version)"
      houdini_activate_env
      echo "Houdini environment ready (prefs set, Poetry venv active)."
      ;;
  esac
}
