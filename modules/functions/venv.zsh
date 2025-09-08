# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Orbit: Environment activation & publish helpers
# ------------------------------------------------------------------

# Deactivate whichever Python env is active (Conda wins if present).
_orbit_py_deactivate() {
  # Conda first (can be nested)
  if [[ -n ${CONDA_SHLVL:-} && ${CONDA_SHLVL} -gt 0 ]] && command -v conda >/dev/null 2>&1; then
    # Deactivate all levels to get to base (safer when switching toolchains)
    while [[ ${CONDA_SHLVL:-0} -gt 0 ]]; do conda deactivate >/dev/null 2>&1 || break; done
  fi

  # Then venv/Poetry (activate script defines 'deactivate')
  if [[ -n ${VIRTUAL_ENV:-} && $(typeset -f deactivate 2>/dev/null) ]]; then
    deactivate >/dev/null 2>&1 || true
  fi
}

# User-facing helper to turn off any active Python env
env_off() { _orbit_py_deactivate; }

_orbit_make_env() {
  local fname=$1         # function name exposed to user
  local project=$2       # folder under packages/
  local conda=$3         # conda env name (used only if ORBIT_USE_CONDA=1)

  eval "
${fname}() {
  local root=\"\$DROPBOX/matrix/packages/${project}\"
  [[ -d \"\$root\" ]] || { echo \"Project not found: \$root\" >&2; return 1; }

  export PROJECT_ROOT=\"\$root\"
  [[ \"\$PWD\" == \"\$root\" ]] || cd \"\$root\"

  if [[ \$ORBIT_PLATFORM == mac ]]; then
    # macOS → Poetry (pyenv already initialized in 10-mac.zsh)
    local venv
    venv=\"\$(poetry env info --path 2>/dev/null)\" || {
      echo 'No Poetry env yet → running poetry install...'
      poetry install || return 1
      venv=\"\$(poetry env info --path 2>/dev/null)\" || return 1
    }
    # Only (de)activate when different from current
    if [[ \"\${VIRTUAL_ENV:-}\" != \"\$venv\" ]]; then
      _orbit_py_deactivate
      source \"\$venv/bin/activate\"
    fi

  elif [[ \$ORBIT_PLATFORM == linux ]]; then
    # Linux → only use Conda if host requested it
    if [[ \"\$ORBIT_USE_CONDA\" == 1 && -n \$(command -v conda) ]]; then
      # If a venv is active, turn it off first
      [[ -n \${VIRTUAL_ENV:-} ]] && _orbit_py_deactivate
      # If a different conda env is active, deactivate first
      if [[ -n \${CONDA_PREFIX:-} ]]; then
        # If already in target, do nothing; else cleanly deactivate to base then activate
        if [[ \${CONDA_DEFAULT_ENV:-} != ${conda} ]]; then
          _orbit_py_deactivate
          conda activate ${conda} || return 1
        fi
      else
        conda activate ${conda} || return 1
      fi
    fi
  fi
}"
}

_orbit_publish() {
  local project="$1"
  local root="$DROPBOX/matrix/packages/${project}"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
  cd "$root" || return 1

  local version_line current_version
  version_line=$(grep '^version' pyproject.toml | head -1)
  current_version=$(echo "$version_line" | sed -E 's/version = "([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')
  IFS='.' read -r major minor patch <<< "$current_version"
  local new_patch=$((patch + 1))
  local new_version="${major}.${minor}.${new_patch}"

  echo "Incrementing version: $current_version -> $new_version"
  sed -i.bak -E "s#(version = \")$current_version(\".*)#\1$new_version\2#" pyproject.toml

  poetry publish --build
  cd - >/dev/null
}

# Define environments (same list as before)
local orbit_projects=(
  usdUtils
  oauthManager
  pythonKitchen
  ocioTools
  helperScripts
  Incept
  pariVaha
  Lumiera
  Ledu
  hdrUtils
)

for project in "${orbit_projects[@]}"; do
  _orbit_make_env "$project" "$project" "$project"
  eval "
    publish_${project}() {
      _orbit_publish $project
    }
  "
done
