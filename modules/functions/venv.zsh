# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Jump into project virtual-envs  ->  usdUtils
# Publish to PyPI                ->  publish_usdUtils
# ------------------------------------------------------------------

############################################################
# Activation helper
############################################################
_orbit_make_env() {
  local fname=$1 project=$2 conda=$3

  eval "
${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \"\$root\" ]] || { echo \"Project not found: \$root\" >&2; return 1; }

  export PROJECT_ROOT=\"\$root\"
  [[ \$PWD == \$root ]] || cd \"\$root\"

  if [[ \$ORBIT_PLATFORM == mac ]]; then
    [[ -n \$VIRTUAL_ENV ]] || source \"\$(poetry env info --path)/bin/activate\"
  elif [[ \$ORBIT_PLATFORM == linux ]]; then
    [[ -n \$CONDA_PREFIX ]] || conda activate ${conda}
  fi
}"
}

############################################################
# Publish helper (quote-safe)
############################################################
_orbit_make_publish() {
  local fname=$1 project=$2
  eval "
publish_${fname}() $(cat <<'EOF'
{
  local root="$DROPBOX/matrix/packages/'${project}'"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }

  (
    cd "$root" || return
    local line ver new_ver
    line=$(grep -E '^version' pyproject.toml | head -1)
    ver=${line#*\"}; ver=${ver%\"*}
    IFS=. read -r M m p <<< "$ver"
    new_ver="$M.$m.$((p+1))"

    sed -i.bak -E "s/(version = \")$ver(\".*)/\\1$new_ver\\2/" pyproject.toml
    echo "Publishing '${project}': $ver → $new_ver"
    poetry publish --build
  )
}
EOF
)"
}

############################################################
# Declare environments once
############################################################
for spec in \
  "usdUtils       usdUtils       usdUtils" \
  "oauthManager   oauthManager   oauthManager" \
  "pythonKitchen  pythonKitchen  pythonKitchen" \
  "ocioTools      ocioTools      ocioTools" \
  "helperScripts  helperScripts  helperScripts" \
  "Incept         Incept         Incept" \
  "pariVaha       pariVaha       pariVaha" \
  "Lumiera        Lumiera        Lumiera" \
  "Ledu           Ledu           Ledu"
do
  set -- $spec
  _orbit_make_env      "$1" "$2" "$3"
  _orbit_make_publish  "$1" "$2"
done

############################################################
# Special one-offs
############################################################
houdiniPublish() {
  export PROJECT_ROOT="$HOME/.virtualenvs/houdiniPublish"
  cd "$PROJECT_ROOT" || return
  source "$PROJECT_ROOT/bin/activate"
}

notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  if [[ $ORBIT_PLATFORM == mac ]]; then
    source "$(poetry env info --path)/bin/activate"
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    conda activate notionUtils
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
