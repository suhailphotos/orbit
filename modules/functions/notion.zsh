# modules/functions/notion.zsh
notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  if [[ $ORBIT_PLATFORM == mac ]]; then
    source "$(poetry env info --path)/bin/activate"
  elif [[ $ORBIT_PLATFORM == linux && "$ORBIT_USE_CONDA" == 1 && -n $(command -v conda) ]]; then
    conda activate notionUtils
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
publish_notionManager() { _orbit_publish notionManager; }
