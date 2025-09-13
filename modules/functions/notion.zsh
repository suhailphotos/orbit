notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  # uv (all platforms by default; Conda still possible on hosts that force it)
  if [[ $ORBIT_PLATFORM == linux && "${ORBIT_USE_CONDA:-0}" == 1 && -n $(command -v conda) ]]; then
    _orbit_py_deactivate; conda activate notionUtils
  else
    _uv_activate_in_project "$PROJECT_ROOT" || return 1
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
