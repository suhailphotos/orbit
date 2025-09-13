# modules/functions/venv.zsh  (UV version)
# ------------------------------------------------------------------
# Orbit: Environment activation & publish helpers (uv-first)
# ------------------------------------------------------------------

# guard: remove any alias called deactivate (zsh would choke on it)
alias deactivate >/dev/null 2>&1 && unalias deactivate

# --- Safe deactivation of whatever is active ----------------------
_orbit_py_deactivate() {
  # Conda first (can be nested)
  if command -v conda >/dev/null 2>&1 && [[ -n ${CONDA_SHLVL:-} && ${CONDA_SHLVL} -gt 0 ]]; then
    while [[ ${CONDA_SHLVL:-0} -gt 0 ]]; do conda deactivate >/dev/null 2>&1 || break; done
  fi
  # Then venv/uv
  if [[ -n ${VIRTUAL_ENV:-} ]] && typeset -f deactivate >/dev/null 2>&1; then
    deactivate >/dev/null 2>&1 || true
  fi
}

# User-facing helper to turn off any active Python env
env_off() { _orbit_py_deactivate; }

# Fallback `deactivate` that never errors when no env is active
_deactivate_fallback() {
  if command -v conda >/dev/null 2>&1 && [[ -n ${CONDA_SHLVL:-} && ${CONDA_SHLVL} -gt 0 ]]; then
    conda deactivate; return
  fi
  echo "No virtual environment is active." >&2
  return 1
}
_orbit_install_deactivate_fallback() {
  if [[ -z ${VIRTUAL_ENV:-} && ${CONDA_SHLVL:-0} -eq 0 ]]; then
    alias deactivate >/dev/null 2>&1 && unalias deactivate
    typeset -f deactivate >/dev/null 2>&1 || deactivate() { _deactivate_fallback "$@"; }
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _orbit_install_deactivate_fallback
_orbit_install_deactivate_fallback
alias da='deactivate'

# --- uv helpers ----------------------------------------------------
_uv_ensure_sync() {
  # Run fast path if lock exists; otherwise allow solver to write uv.lock
  if [[ -f uv.lock ]]; then
    uv sync --frozen
  else
    uv lock
    uv sync
  fi
}

_uv_activate_in_project() {
  local root="$1"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
  cd "$root" || return 1

  # Make sure we’re not “carrying” someone else’s venv (prevents your Ledu warning)
  _orbit_py_deactivate

  # Ensure a venv exists (uv will create .venv if missing)
  if [[ ! -d .venv ]]; then
    uv venv --python "$(uv python find --project 2>/dev/null || echo 3.11)"
  fi

  # Bring deps up to date
  _uv_ensure_sync

  # Activate (idempotent)
  source ".venv/bin/activate"
}

# --- Optional: Conda override on Linux hosts that insist on it ---------------
# Leave as-is if ORBIT_USE_CONDA=1 (e.g., nimbus). Otherwise use uv.
_conda_or_uv() {
  local root="$1" conda_env="$2"
  if [[ $ORBIT_PLATFORM == linux && "${ORBIT_USE_CONDA:-0}" == 1 ]] && command -v conda >/dev/null 2>&1; then
    _orbit_py_deactivate
    conda activate "$conda_env" || return 1
  else
    _uv_activate_in_project "$root"
  fi
}

# --- Project wrappers ---------------------------------------------------------
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
  _conda_or_uv \"\$root\" ${conda:q} || return 1
  echo \"→ ${project} active [\$PWD]\"
}"
}

# (Optional) publisher: uv build + twine (you can wire PyPI creds via keyring/op)
_orbit_publish() {
  local project="$1"
  local root="$DROPBOX/matrix/packages/${project}"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
  cd "$root" || return 1

  _uv_activate_in_project "$root" || return 1
  rm -rf dist build 2>/dev/null || true
  uv build || return 1
  # If you use 1Password/Keyring, 'uv publish' may also be available in your uv version.
  # Otherwise, twine:
  if command -v twine >/dev/null 2>&1; then
    twine upload dist/*
  else
    echo "Built artifacts in ./dist (install twine or use 'uv publish' if available)."
  fi
}

# Define environments (same list you had)
local orbit_projects=(usdUtils oauthManager pythonKitchen ocioTools helperScripts Incept pariVaha Lumiera Ledu hdrUtils)
for project in "${orbit_projects[@]}"; do
  _orbit_make_env "$project" "$project" "$project"
  eval "publish_${project}() { _orbit_publish $project; }"
done
