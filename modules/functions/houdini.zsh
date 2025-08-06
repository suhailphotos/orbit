# modules/functions/houdini.zsh
# ------------------------------------------------------------------
# Houdini utility functions: activate env, patch houdini.env, launch, etc.
# ------------------------------------------------------------------

houdini_utils_path() {
  echo "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils"
}

houdini_version() {
  # Return latest version, or user-provided as arg
  if [[ -n "$1" ]]; then
    echo "$1"
  else
    ls -d /Applications/Houdini/Houdini* 2>/dev/null | \
      sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1
  fi
}

houdini_set_user_pref() {
  local version="${1:-$(houdini_version)}"
  export HOUDINI_USER_PREF_DIR="$HOME/Library/CloudStorage/Dropbox/appSettings/houdini/mac/${version%.*}"
}

houdini_activate_env() {
  local env_dir="$(houdini_utils_path)"
  cd "$env_dir" || return 1
  if [[ -z "$VIRTUAL_ENV" ]]; then
    source "$(poetry env info --path)/bin/activate" || return 1
  fi
}

houdini_patch_env() {
  # Add the site-packages path to houdini.env if missing
  local env_name="${1:-houdiniUtils}"
  houdini_set_user_pref "$(houdini_version)"
  local env_dir="$HOME/Library/CloudStorage/Dropbox/matrix/packages/$env_name"
  cd "$env_dir" || return 1
  local poetry_env_path
  poetry_env_path=$(poetry env info --path)
  [[ -z "$poetry_env_path" ]] && echo "Error: Poetry env path not found" && return 1
  local python_packages_path="$poetry_env_path/lib/python3.11/site-packages"
  local houdini_env_file="$HOUDINI_USER_PREF_DIR/houdini.env"

  grep -q "$python_packages_path" "$houdini_env_file" 2>/dev/null || {
    echo "PYTHONPATH=\"\$PYTHONPATH:$python_packages_path\"" >> "$houdini_env_file"
    echo "Added $python_packages_path to $houdini_env_file"
  }
}

houdini_open_vscode() {
  local file="$1"
  [[ -z "$file" ]] && echo "No file specified" && return 1
  open -a "Visual Studio Code" "$file"
  sleep 1
}

# Main entry: one function to setup everything
houdiniUtils() {
  local cmd="$1"
  if [[ "$cmd" == "patchenv" ]]; then
    houdini_patch_env houdiniUtils
  elif [[ "$cmd" == "vscode" && -n "$2" ]]; then
    houdini_open_vscode "$2"
  else
    houdini_set_user_pref "$(houdini_version)"
    houdini_activate_env
    echo "Houdini environment ready (user prefs, venv active)."
  fi
}
