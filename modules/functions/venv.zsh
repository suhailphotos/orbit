# modules/functions/venv.zsh
# ------------------------------------------------------------------
# 1)  <envName>         – cd & activate env  (Poetry on mac / Conda on linux)
# 2)  publish_<envName> – bump patch, build & poetry publish
# ------------------------------------------------------------------

############################################################
# Helper 1 – activation generator
############################################################
_orbit_make_env() {
  local fname=$1 project=$2 conda=$3

  eval "
${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \$root ]] || { echo \"Project not found: \$root\" >&2; return 1; }

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
# Helper 2 – publish generator (quote-safe)
############################################################
_orbit_make_publish() {
  local fname=$1 project=$2
  eval "
publish_${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \$root ]] || { echo \"Project not found: \$root\" >&2; return 1; }

  (   # subshell => keep caller's CWD clean
      cd \"\$root\" || return
      local ver line new_ver
      line=\$(grep -E '^version' pyproject.toml | head -1)
      ver=\${line#*\"}; ver=\${ver%\"*}
      IFS=. read -r MAJ MIN PAT <<< \"\$ver\"
      new_ver=\"\$MAJ.\$MIN.\$((PAT+1))\"

      sed -i.bak -E \"s/(version = \\\".)\${ver}(\\\")/\\1\${new_ver}\\2/\" pyproject.toml
      echo \"Publishing ${project}: \$ver → \$new_ver\"
      poetry publish --build
  )
}"
}

############################################################
# Declare your envs once
############################################################
for spec in \
  "usdUtils usdUtils usdUtils" \
  "oauthManager oauthManager oauthManager" \
  "pythonKitchen pythonKitchen pythonKitchen" \
  "ocioTools ocioTools ocioTools" \
  "helperScripts helperScripts helperScripts" \
  "Incept Incept Incept" \
  "pariVaha pariVaha pariVaha" \
  "Lumiera Lumiera Lumiera" \
  "Ledu Ledu Ledu"
do
  set -- $spec        # -> $1=fname $2=project $3=condaName
  _orbit_make_env      "$1" "$2" "$3"
  _orbit_make_publish  "$1" "$2"
done

############################################################
# Special one-offs that don’t match the pattern
############################################################
houdiniPublish() {
  export PROJECT_ROOT="$HOME/.virtualenvs/houdiniPublish"
  cd "$PROJECT_ROOT" || return
  source "$PROJECT_ROOT/bin/activate"
}

notionManager() {
  export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
  cd "$PROJECT_ROOT" || return
  if [[ $ORBIT_PLATFORM == mac ]];  then
    source "$(poetry env info --path)/bin/activate"
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    conda activate notionUtils
  fi
  export PREFECT_API_URL="${PREFECT_API_URL:-http://10.81.29.44:4200/api}"
}
