notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  if [[ $ORBIT_PLATFORM == mac ]]; then
    local venv; venv="$(poetry env info --path 2>/dev/null)" || {
      echo 'No Poetry env yet → running poetry install...'
      poetry install || return 1
      venv="$(poetry env info --path 2>/dev/null)" || return 1
    }
    if [[ "${VIRTUAL_ENV:-}" != "$venv" ]]; then
      _orbit_py_deactivate
      source "$venv/bin/activate"
    fi
  elif [[ $ORBIT_PLATFORM == linux && "$ORBIT_USE_CONDA" == 1 && -n $(command -v conda) ]]; then
    _orbit_py_deactivate
    conda activate notionUtils
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
