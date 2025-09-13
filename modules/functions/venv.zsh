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

# Resolve Orbit's default Python spec (knob), avoiding hard-codes.
# Returns one of:
#   - value of $ORBIT_UV_DEFAULT_PY if set to a version spec or absolute path
#   - "MAJOR.MINOR" derived from Houdini's Python when ORBIT_UV_DEFAULT_PY=auto-houdini
#   - absolute path to system python3 as a last resort
_orbit_uv_default_python_spec() {
  local mode="${ORBIT_UV_DEFAULT_PY:-auto-houdini}"
  if [[ "$mode" != "auto-houdini" && -n "$mode" ]]; then
    echo "$mode"
    return 0
  fi

  # auto-houdini → derive MAJOR.MINOR from SideFX Python if we can
  if [[ "${ORBIT_HAS_HOUDINI:-0}" == 1 ]]; then
    local pybin=""
    if [[ "$ORBIT_PLATFORM" == mac && -n "${ORBIT_HOUDINI_ROOT:-}" ]]; then
      local root="$ORBIT_HOUDINI_ROOT"
      pybin="$root/Frameworks/Houdini.framework/Versions/Current/Resources/Frameworks/Python.framework/Versions/Current/bin/python3"
    elif [[ "$ORBIT_PLATFORM" == linux && -n "${ORBIT_HOUDINI_ROOT:-}" ]]; then
      local HFS="$ORBIT_HOUDINI_ROOT"
      for c in "$HFS/bin/python3.12" "$HFS/bin/python3.11" "$HFS/bin/python3.10" "$HFS/bin/python3"; do
        [[ -x "$c" ]] && { pybin="$c"; break; }
      done
    fi
    if [[ -x "$pybin" ]]; then
      local minor
      minor="$("$pybin" -c 'import sys;print(f"{sys.version_info[0]}.{sys.version_info[1]}")' 2>/dev/null || true)"
      [[ -n "$minor" ]] && { echo "$minor"; return 0; }
    fi
  fi

  # last resort: use the system python3 absolute path so uv accepts it
  local sys; sys="$(command -v python3 2>/dev/null || true)"
  if [[ -n "$sys" ]]; then echo "$sys"; return 0; fi
  echo "3"   # ultimate fallback: latest available Python 3.x
}

# Returns the interpreter uv thinks this project should use,
# based on pyproject.toml [project.requires-python], .python-version, runtime.txt, etc.
# Prefer project's declared runtime; fallback to Orbit knob
_uv_desired_python_for_project() {
  local root="$1"
  local spec=""
  spec="$( (cd "$root" && uv python find --project 2>/dev/null) || true )"
  if [[ -n "$spec" ]]; then
    echo "$spec"
  else
    _orbit_uv_default_python_spec
  fi
}

_uv_activate_in_project() {
  local root="$1"
  [[ -d "$root" ]] || { echo "Project not found: $root" >&2; return 1; }
  cd "$root" || return 1

  _orbit_py_deactivate

  local envroot="${UV_PROJECT_ENVIRONMENT:-${ORBIT_UV_VENV_ROOT:-$HOME/.venvs}/${root:t}}"
  export UV_PROJECT_ENVIRONMENT="$envroot"

  local want_spec; want_spec="$(_uv_desired_python_for_project "$root")"

  local need_rebuild=0 cur_ver="" want_ver="" want_path=""
  if [[ -x "$envroot/bin/python" ]]; then
    cur_ver="$("$envroot/bin/python" -c 'import platform;print(platform.python_version())' 2>/dev/null || true)"
    want_path="$(uv python find "$want_spec" 2>/dev/null || true)"
    [[ -n "$want_path" ]] && want_ver="$("$want_path" -c 'import platform;print(platform.python_version())' 2>/dev/null || true)"
    [[ -z "$cur_ver" || -z "$want_ver" || "$cur_ver" != "$want_ver" ]] && need_rebuild=1
  else
    need_rebuild=1
  fi

  if (( need_rebuild )); then
    rm -rf -- "$envroot" 2>/dev/null || true
    local q=""; (( ORBIT_UV_QUIET )) && q="-q"
    uv venv --python "$want_spec" $q || return 1
    # First-time or rebuilt env → do one sync so it's usable
    if [[ -f uv.lock ]]; then uv sync --frozen $q; else uv lock $q && uv sync $q; fi
  elif (( ORBIT_UV_SYNC_ON_ACTIVATE || ORBIT_UV_FORCE_SYNC )); then
    # Optional: on-demand syncs when explicitly requested
    local q=""; (( ORBIT_UV_QUIET )) && q="-q"
    if [[ -f uv.lock ]]; then uv sync --frozen $q; else uv lock $q && uv sync $q; fi
  fi
  source "$envroot/bin/activate"
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
  (( ORBIT_UV_QUIET )) || echo \"→ ${project} active [\$PWD]\"
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

# Define wrappers for configured projects
typeset -ga ORBIT_PROJECTS
# Fallback defaults if 45-projects.zsh didn't set ORBIT_PROJECTS
if (( ! ${#ORBIT_PROJECTS[@]} )); then
  ORBIT_PROJECTS=(
    Incept
    Lumiera
    Ledu
    hdrUtils
  )
fi

for project in "${ORBIT_PROJECTS[@]}"; do
  _orbit_make_env "$project" "$project" "$project"
  eval "publish_${project}() { _orbit_publish ${(q)project}; }"
done
