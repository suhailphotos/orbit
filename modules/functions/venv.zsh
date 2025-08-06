# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Jump into project virtual-envs   e.g.  usdUtils
# ------------------------------------------------------------------

_orbit_make_env() {
  local fname=$1         # function name exposed to user
  local project=$2       # folder under packages/
  local conda=$3         # conda env name (linux only)

  eval "
${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \"\$root\" ]] || { echo \"Project not found: \$root\" >&2; return 1; }

  export PROJECT_ROOT=\"\$root\"
  [[ \"\$PWD\" == \"\$root\" ]] || cd \"\$root\"

  if [[ \$ORBIT_PLATFORM == mac ]]; then
    [[ -n \$VIRTUAL_ENV ]] || source \"\$(poetry env info --path)/bin/activate\"
  elif [[ \$ORBIT_PLATFORM == linux ]]; then
    [[ -n \$CONDA_PREFIX ]] || conda activate ${conda}
  fi
}"
}

# -------------------------
# Define the environments
# -------------------------
_orbit_make_env usdUtils       usdUtils       usdUtils
_orbit_make_env oauthManager   oauthManager   oauthManager
_orbit_make_env pythonKitchen  pythonKitchen  pythonKitchen
_orbit_make_env ocioTools      ocioTools      ocioTools
_orbit_make_env helperScripts  helperScripts  helperScripts
_orbit_make_env Incept         Incept         Incept
_orbit_make_env pariVaha       pariVaha       pariVaha
_orbit_make_env Lumiera        Lumiera        Lumiera
_orbit_make_env Ledu           Ledu           Ledu

# ---------- Special one-offs ----------
houdiniPublish() {
  export PROJECT_ROOT="$HOME/.virtualenvs/houdiniPublish"
  cd "$PROJECT_ROOT" || return
  source "$PROJECT_ROOT/bin/activate"
}

notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  if [[ $ORBIT_PLATFORM == mac ]];  then source "$(poetry env info --path)/bin/activate"
  elif [[ $ORBIT_PLATFORM == linux ]]; then conda activate notionUtils
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
