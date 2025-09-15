# modules/env/35-uv.zsh
# External, per-project uv envs + automatic env var export on cd.

: ${ORBIT_UV_VENV_ROOT:="$HOME/.venvs"}     # where project envs live (plural)
: ${ORBIT_UV_DEFAULT_PY:="auto-houdini"}   # fallback interpreter spec (the knob)

# --- uv "tool" shims (global CLIs installed by `uv tool`) ---
if command -v uv >/dev/null 2>&1; then
  _uv_tool_dir="$(uv tool dir 2>/dev/null || true)"
  if [[ -n "$_uv_tool_dir" ]]; then
    # Ensure the bin exists even before first install
    mkdir -p "$_uv_tool_dir/bin"
    orbit_prepend_path "$_uv_tool_dir/bin"
  fi
  unset _uv_tool_dir
else
  # Fallback for machines without uv yet (use XDG default)
  _uv_fallback="${XDG_DATA_HOME:-$HOME/.local/share}/uv/tools/bin"
  [[ -d "$_uv_fallback" ]] && orbit_prepend_path "$_uv_fallback"
  unset _uv_fallback
fi


# Find project root: prefer git; else walk up for pyproject.toml
_orbit_uv_project_root() {
  local root
  if root="$(git -C . rev-parse --show-toplevel 2>/dev/null)"; then
    [[ -f "$root/pyproject.toml" ]] && { echo "$root"; return 0; }
  fi
  local d="$PWD"
  while [[ "$d" != "/" ]]; do
    [[ -f "$d/pyproject.toml" ]] && { echo "$d"; return 0; }
    d="${d:h}"
  done
  return 1
}

_orbit_uv_env_for() {
  local root="$1"
  echo "${ORBIT_UV_VENV_ROOT}/${root:t}"
}

# Centralized setter/unsetter
_orbit_uv_set_envvar() {
  local root; root="$(_orbit_uv_project_root)" || { unset UV_PROJECT_ENVIRONMENT; return; }
  export UV_PROJECT_ENVIRONMENT="$(_orbit_uv_env_for "$root")"
}

# Keep it in sync on cd and before each prompt
autoload -Uz add-zsh-hook
add-zsh-hook chpwd  _orbit_uv_set_envvar
add-zsh-hook precmd _orbit_uv_set_envvar

# Safety wrapper: ensure envvar is set before any uv command runs
# Falls through to the real uv (avoid recursion with `command`).
uv() {
  # Only bother for project commands; cheap to compute.
  _orbit_uv_set_envvar
  command uv "$@"
}

# QoL
uvp()       { print -r -- "${UV_PROJECT_ENVIRONMENT:-"(unset)"}"; }
uvensure()  {
  local q=""; (( ORBIT_UV_QUIET )) && q="-q"
  [[ -f uv.lock ]] && uv sync --frozen $q || { uv lock $q && uv sync $q; }
}
