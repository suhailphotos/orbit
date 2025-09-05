# modules/functions/houdini.zsh

# If Houdini isn't installed, define stubs and exit quietly
if [[ "${ORBIT_HAS_HOUDINI:-0}" != 1 ]]; then
  houdiniUtils() { return 1; }
  return
fi

# Cross-platform pref dir
_houdini_pref_dir() {
  local ver_mm="${1%.*}"  # X.Y from X.Y.Z
  case "$ORBIT_PLATFORM" in
    mac)  echo "$HOME/Library/Preferences/houdini/$ver_mm" ;;
    linux) echo "$HOME/houdini$ver_mm" ;;
    wsl)  echo "$HOME/Documents/houdini$ver_mm" ;;  # Git Bash/MSYS
    *)    echo "$HOME/houdini$ver_mm" ;;
  esac
}

houdini_utils_path() {
  echo "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils"
}

houdini_version() {
  if [[ -n "$1" ]]; then
    echo "$1"
  elif [[ $ORBIT_PLATFORM == mac ]]; then
    ls -d /Applications/Houdini/Houdini* 2>/dev/null | sed 's|.*/Houdini||' | sort -Vr | head -n 1
  elif [[ $ORBIT_PLATFORM == linux && -n ${HFS-} ]]; then
    basename "$HFS" | sed 's|^hfs||'   # hfs20.5.123 -> 20.5.123
  else
    echo ""
  fi
}

# Export for this shell/session only when explicitly requested
houdini_set_user_pref() {
  local version="${1:-$(houdini_version)}"
  [[ -n $version ]] || { echo "Cannot determine Houdini version"; return 1; }
  export HOUDINI_USER_PREF_DIR="$(_houdini_pref_dir "$version")"
  mkdir -p "$HOUDINI_USER_PREF_DIR"
}

# Optional: activate your poetry env for a package you’re hacking on
houdini_activate_env() {
  local project="${1:-houdiniUtils}"
  local env_dir="$DROPBOX/matrix/packages/$project"
  cd "$env_dir" || return 1
  [[ -n $VIRTUAL_ENV ]] || source "$(poetry env info --path)/bin/activate"
}

# Bootstrap HFS env (mac/linux)
houdini_bootstrap_hfs_env() {
  local ver="${1:-$(houdini_version)}"
  if [[ $ORBIT_PLATFORM == mac ]]; then
    local RES="/Applications/Houdini/Houdini${ver}/Frameworks/Houdini.framework/Versions/Current/Resources"
    [[ -d $RES ]] || { echo "Houdini resources not found: $RES"; return 1; }
    export PYTHONPATH="$RES/houdini/python3.11libs:${PYTHONPATH:-}"
    source "$RES/houdini_setup" || return 1
  elif [[ $ORBIT_PLATFORM == linux && -n ${HFS-} ]]; then
    source "$HFS/houdini_setup" || return 1
  fi
}

# Write site-packages into houdini.env of the (default) pref dir
houdini_patch_env() {
  local project="${1:-houdiniUtils}"
  local ver="${2:-$(houdini_version)}"
  houdini_set_user_pref "$ver" || return 1
  local env_dir="$DROPBOX/matrix/packages/$project"
  cd "$env_dir" || return 1
  local ppath="$(poetry env info --path 2>/dev/null)"
  [[ -n $ppath ]] || { echo "Poetry env not found for $project"; return 1; }
  local site="$ppath/lib/python3.11/site-packages"
  local f="$HOUDINI_USER_PREF_DIR/houdini.env"
  touch "$f"
  grep -q "$site" "$f" || {
    printf 'PYTHONPATH="$PYTHONPATH:%s"\n' "$site" >> "$f"
    echo "Added $site to $f"
  }
}

# Convenience: run your Tessera stow
tessera_houdini_stow() {
  "$DROPBOX/matrix/tessera/helper/houdini_stow.sh" "${1:-}"
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
# Main entry
houdiniUtils() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    patchenv)  houdini_patch_env "${1:-houdiniUtils}" "${2:-$(houdini_version)}" ;;
    -e|-hou)
      local ver="$(houdini_version "${1:-}")"
      houdini_set_user_pref "$ver" || return 1
      [[ -n "${2:-}" ]] && shift || true
      houdini_activate_env "${1:-houdiniUtils}" || true
      houdini_bootstrap_hfs_env "$ver" || return 1
      [[ "$cmd" == "-hou" ]] && python3 - <<'PY' || true
print("import hou bootstrap here if you like")
PY
      ;;
    *)
      houdini_set_user_pref "$(houdini_version)" || return 1
      echo "Houdini prefs: $HOUDINI_USER_PREF_DIR"
      ;;
  esac
}
