# modules/functions/pkg.zsh  (UV version)
: ${PACKAGES_ROOT:="${MATRIX:-$DROPBOX/matrix}/packages"}
typeset -a HOU_PACKAGES
HOU_PACKAGES=(${HOU_PACKAGES:-houdiniLab houdiniUtils})

_pkg_ci() {
  local needle="$1"
  for d in "$PACKAGES_ROOT"/*; do
    [[ -d $d ]] || continue
    [[ "${d:t:l}" == "${needle:l}" ]] && { echo "$d"; return 0; }
  done; return 1
}
_pkg_resolve_root() {
  local arg="$1"
  if [[ -d "$arg" ]]; then echo "${arg:A}"; return 0; fi
  [[ -d "$PACKAGES_ROOT/$arg" ]] && { echo "$PACKAGES_ROOT/$arg"; return 0; }
  _pkg_ci "$arg" && return 0; return 1
}
_pkg_is_houdini_pkg() {
  local name="$1"; for p in "${HOU_PACKAGES[@]}"; do
    [[ "${p:l}" == "${name:l}" ]] && return 0
  done; return 1
}
# Use the shared activator that works in the **current** shell
_pkg_uv_activate() {
  _uv_activate_in_project "$1"
}

pkg() {
  emulate -L zsh; setopt pipefail
  [[ -z "$1" ]] && { echo "Usage: pkg <name|path> [--hou [VER|latest]] [--cd-only]"; return 1; }
  local target="$1"; shift
  local want_hou=0 ver="" cd_only=0 force_sync=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --hou) want_hou=1; [[ -n "${2-}" && "${2:0:2}" != "--" ]] && { ver="$2"; shift; } ;;
      --hou=*) want_hou=1; ver="${1#--hou=}";;
      --cd-only) cd_only=1;;
      *) echo "pkg: unknown flag '$1'"; return 1;;
    esac; shift
  done

  local root; root="$(_pkg_resolve_root "$target")" || { echo "pkg: not found → $target"; return 1; }
  local name="${root:t}"
  local envroot="${ORBIT_UV_VENV_ROOT:-$HOME/.venvs}/${name}"

  cd "$root" || return 1

  # clean up any unrelated, previously-active env
  if [[ -n ${VIRTUAL_ENV:-} && "${VIRTUAL_ENV:A}" != "${envroot:A}" ]]; then
    if typeset -f deactivate >/dev/null 2>&1; then deactivate >/dev/null 2>&1 || true; fi
    unset VIRTUAL_ENV
    hash -r 2>/dev/null || true
  fi

  (( cd_only )) && { pwd; return 0; }

  if (( want_hou )) || _pkg_is_houdini_pkg "$name"; then
    ORBIT_UV_FORCE_SYNC=$force_sync hou use "${ver:-latest}" || return 1
  else
    (( force_sync )) && export ORBIT_UV_FORCE_SYNC=1
    _pkg_uv_activate "$root" || { echo "pkg: uv activation failed."; return 1; }
    (( force_sync )) && unset ORBIT_UV_FORCE_SYNC
  fi
  (( ORBIT_UV_QUIET )) || echo "→ ${name} active [$PWD]"
}

mkpkg() {
  emulate -L zsh
  [[ -n "$1" ]] || { echo "Usage: mkpkg <name|path> [--hou [VER]] [--alias NAME]"; return 1; }
  local target="$1"; shift
  local alias="" want_hou=0 ver=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --alias) alias="$2"; shift;;
      --alias=*) alias="${1#--alias=}";;
      --hou) want_hou=1; [[ -n "${2-}" && "${2:0:2}" != "--" ]] && { ver="$2"; shift; } ;;
      --hou=*) want_hou=1; ver="${1#--hou=}";;
      *) echo "mkpkg: unknown flag '$1'"; return 1;;
    esac; shift
  done
  local root; root="$(_pkg_resolve_root "$target")" || { echo "mkpkg: not found → $target"; return 1; }
  local name="${alias:-${root:t}}"
  local houflag=""; (( want_hou )) && houflag="--hou ${ver:+$ver}"
  eval "${name}() { pkg ${(q)root} ${houflag}; }"
  echo "→ Defined function: ${name}  (calls: pkg ${(q)root} ${houflag})"
}
