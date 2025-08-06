# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Quickly jump into project virtual-envs (Poetry on mac, Conda on linux)
# Usage:  usdUtils        -> cd & activate env
#         publish_usdUtils -> bump patch + poetry publish
# ------------------------------------------------------------------

# ------------------------------------------------------------
# Helper: build two functions per project (activate + publish)
# ------------------------------------------------------------
_orbit_make_env() {
  local fname=$1         # function name shown to user
  local project=$2       # folder name under packages/
  local conda=$3         # conda env name (linux only)

  # ==== activate function ====
  eval "${fname}() {
    local root=\"\$DROPBOX/matrix/packages/${project}\"
    [[ -d \$root ]] || { echo \"Project not found: \$root\" >&2; return 1; }

    # Export so child tools know where they are
    export PROJECT_ROOT=\"\$root\"

    # mac → Poetry; linux → Conda
    if [[ \$ORBIT_PLATFORM == mac ]]; then
      [[ \${PWD} == \$root ]] || cd \"\$root\"
      [[ -n \$VIRTUAL_ENV ]] || source \"\$(poetry env info --path)/bin/activate\"
    elif [[ \$ORBIT_PLATFORM == linux ]]; then
      [[ \${PWD} == \$root ]] || cd \"\$root\"
      [[ -n \$CONDA_PREFIX ]] || conda activate ${conda}
    fi
  }"

  # ==== publish function ====
  eval "publish_${fname}() {
    local root=\"\$DROPBOX/matrix/packages/${project}\"
    [[ -d \$root ]] || { echo \"Project not found: \$root\" >&2; return 1; }
    (  # subshell to avoid directory bleed
       cd \"\$root\" || return
       local ver line new_ver
       line=\$(grep -E '^version' pyproject.toml | head -1)
       ver=\${line#*\"}; ver=\${ver%\"*}
       IFS=. read -r MAJ MIN PAT <<< \"\$ver\"
       new_ver=\"\$MAJ.\$MIN.\$((PAT+1))\"

       sed -i.bak -E \"s/(version = \\\")\$ver(\\\")/\\1\$new_ver\\2/\" pyproject.toml
       echo \"Publishing \$project \$ver → \$new_ver\"
       poetry publish --build
    )
  }"
}

# -------------------------------------
# Define your environments **once** here
# -------------------------------------
_orbit_make_env usdUtils       usdUtils       usdUtils
_orbit_make_env oauthManager   oauthManager   oauthManager
_orbit_make_env pythonKitchen  pythonKitchen  pythonKitchen
_orbit_make_env ocioTools      ocioTools      ocioTools
_orbit_make_env helperScripts  helperScripts  helperScripts
_orbit_make_env Incept         Incept         Incept
_orbit_make_env pariVaha       pariVaha       pariVaha
_orbit_make_env Lumiera        Lumiera        Lumiera
_orbit_make_env Ledu           Ledu           Ledu

# Special cases that don’t fit the pattern
houdiniPublish() {
  export PROJECT_ROOT="$HOME/.virtualenvs/houdiniPublish"
  cd "$PROJECT_ROOT" || return
  source "$PROJECT_ROOT/bin/activate"
}

notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  [[ $ORBIT_PLATFORM == mac ]] && source "$(poetry env info --path)/bin/activate"
  [[ $ORBIT_PLATFORM == linux ]] && conda activate notionUtils
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
  cd "$PROJECT_ROOT"
}
