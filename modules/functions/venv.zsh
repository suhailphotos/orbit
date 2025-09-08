# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Orbit: Environment activation & publish helpers
# ------------------------------------------------------------------

# --- Safe deactivation layer (venv & Conda) -----------------------
_orbit_deactivate_any() {
  # venv (Python virtualenv/poetry/uv): they inject a 'deactivate' *function*
  if typeset -f deactivate >/dev/null 2>&1; then
    deactivate >/dev/null 2>&1 || true
  fi

  # Conda: if an env is active, step down one level
  if [[ -n ${CONDA_SHLVL-} && ${CONDA_SHLVL} -gt 0 ]] && command -v conda >/dev/null 2>&1; then
    conda deactivate >/dev/null 2>&1 || true
  fi
}

# User-facing wrapper so "deactivate" never errors when nothing is active
venv_deactivate() {
  # If a venv's own deactivate function exists, call it
  if typeset -f deactivate >/dev/null 2>&1; then
    deactivate
    return
  fi

  # If a Conda env is active, step down
  if [[ -n ${CONDA_SHLVL-} && ${CONDA_SHLVL} -gt 0 ]] && command -v conda >/dev/null 2>&1; then
    conda deactivate
    return
  fi

  echo "No virtual environment is active." >&2
  return 1
}

# Make both 'deactivate' and 'da' point to our wrapper when no venv is active.
# (When a venv IS active, its function named 'deactivate' overrides this alias.)
alias deactivate='venv_deactivate'
alias da='venv_deactivate'

# --- Project helpers ---------------------------------------------------------
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
    _orbit_deactivate_any
    local vpath
    vpath=\"\$(poetry env info --path 2>/dev/null)\" || { echo 'Poetry venv not found. Try: poetry install' >&2; return 1; }
    source \"\$vpath/bin/activate\"
  elif [[ \$ORBIT_PLATFORM == linux ]]; then
    # Linux → only use Conda if host requested it
    if [[ \"\$ORBIT_USE_CONDA\" == 1 && -n \$(command -v conda) ]]; then
      _orbit_deactivate_any
      conda activate ${conda}
    else
      # Optional: fall back to Poetry on Linux if you want parity
      if command -v poetry >/dev/null 2>&1; then
        _orbit_deactivate_any
        local vpath
        vpath=\"\$(poetry env info --path 2>/dev/null)\" || { echo 'Poetry venv not found. Try: poetry install' >&2; return 1; }
        source \"\$vpath/bin/activate\"
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
