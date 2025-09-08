# modules/functions/venv.zsh
# ------------------------------------------------------------------
# Orbit: Environment activation & publish helpers
# ------------------------------------------------------------------

# --- Safe deactivation of whatever is active ----------------------
_orbit_py_deactivate() {
  # Conda first (can be nested)
  if command -v conda >/dev/null 2>&1 && [[ -n ${CONDA_SHLVL:-} && ${CONDA_SHLVL} -gt 0 ]]; then
    # Deactivate all levels to get to base (safer when switching toolchains)
    while [[ ${CONDA_SHLVL:-0} -gt 0 ]]; do conda deactivate >/dev/null 2>&1 || break; done
  fi

  # Then venv/Poetry (only if actually active)
  if [[ -n ${VIRTUAL_ENV:-} ]] && typeset -f deactivate >/dev/null 2>&1; then
    deactivate >/dev/null 2>&1 || true
  fi
}

# User-facing helper to turn off any active Python env
env_off() { _orbit_py_deactivate; }

# --- Fallback `deactivate` that never errors when no env is active --
# We (re)install this only when there is no venv/conda active and no
# other `deactivate` function is defined. A venv will override it
# while active; after deactivation (which usually unsets itself),
# our precmd hook below restores this fallback.
_deactivate_fallback() {
  # If a Conda env is active (but venv isn't), step down one level.
  if command -v conda >/dev/null 2>&1 && [[ -n ${CONDA_SHLVL:-} && ${CONDA_SHLVL} -gt 0 ]]; then
    conda deactivate
    return
  fi
  echo "No virtual environment is active." >&2
  return 1
}

_orbit_install_deactivate_fallback() {
  # Only when *no* venv/conda is active and no other `deactivate` exists
  if [[ -z ${VIRTUAL_ENV:-} && ${CONDA_SHLVL:-0} -eq 0 ]]; then
    if ! typeset -f deactivate >/dev/null 2>&1; then
      deactivate() { _deactivate_fallback "$@"; }
    fi
  fi
}

# Install once now, and re-check before each prompt (restores after venv deactivates)
autoload -Uz add-zsh-hook
add-zsh-hook precmd _orbit_install_deactivate_fallback
_orbit_install_deactivate_fallback

# Convenience: `da` → `deactivate`
alias da='deactivate'

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
    if [[ \"\$ORBIT_USE_CONDA\" == 1 ]] && command -v conda >/dev/null 2>&1; then
      # If a venv is active, turn it off first
      [[ -n \${VIRTUAL_ENV:-} ]] && _orbit_py_deactivate
      # If a different conda env is active, deactivate first
      if [[ -n \${CONDA_PREFIX:-} ]]; then
        if [[ \${CONDA_DEFAULT_ENV:-} != ${conda} ]]; then
          _orbit_py_deactivate
          conda activate ${conda} || return 1
        fi
      else
        conda activate ${conda} || return 1
      fi
    else
      # Optional: Poetry fallback on Linux for parity
      if command -v poetry >/dev/null 2>&1; then
        local venv
        venv=\"\$(poetry env info --path 2>/dev/null)\" || {
          echo 'No Poetry env yet → running poetry install...'
          poetry install || return 1
          venv=\"\$(poetry env info --path 2>/dev/null)\" || return 1
        }
        if [[ \"\${VIRTUAL_ENV:-}\" != \"\$venv\" ]]; then
          _orbit_py_deactivate
          source \"\$venv/bin/activate\"
        fi
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
  current_version=$(echo "$version_line" | sed -E 's/version = \"([0-9]+\.[0-9]+\.[0-9]+)\".*/\1/')
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
