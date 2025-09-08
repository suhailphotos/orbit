# modules/functions/pkg.zsh
# Jump to a package and activate its env. Optional: ensure SideFX Python first.

: ${PACKAGES_ROOT:="${MATRIX:-$DROPBOX/matrix}/packages"}
typeset -a HOU_PACKAGES
HOU_PACKAGES=(${HOU_PACKAGES:-houdiniLab houdiniUtils})  # override in secrets/.env if you like

# case-insensitive match helper
_pkg_ci() {
  local needle="$1"
  for d in "$PACKAGES_ROOT"/*; do
    [[ -d $d ]] || continue
    [[ "${d:t:l}" == "${needle:l}" ]] && { echo "$d"; return 0; }
  done
  return 1
}

# find a poetry project root from name or absolute path
_pkg_resolve_root() {
  local arg="$1"
  if [[ -d "$arg" ]]; then
    echo "${arg:A}"; return 0
  fi
  [[ -d "$PACKAGES_ROOT/$arg" ]] && { echo "$PACKAGES_ROOT/$arg"; return 0; }
  _pkg_ci "$arg" && return 0
  return 1
}

# poetry venv activator (quiet if already active)
_pkg_poetry_activate() {
  local root="$1"
  local venv
  venv="$(cd "$root" && poetry env info --path 2>/dev/null)" || return 1

  # only switch if different
  if [[ "${VIRTUAL_ENV:-}" != "$venv" ]]; then
    _orbit_py_deactivate
    source "$venv/bin/activate"
  fi
}

# does this package want Houdini by default?
_pkg_is_houdini_pkg() {
  local name="$1"
  for p in "${HOU_PACKAGES[@]}"; do
    [[ "${p:l}" == "${name:l}" ]] && return 0
  done
  return 1
}

# main: pkg
pkg() {
  emulate -L zsh
  setopt pipefail
  if [[ -z "$1" ]]; then
    echo "Usage: pkg <name|path> [--hou [VER|latest]] [--cd-only]"; return 1
  fi

  local target="$1"; shift
  local want_hou=0 ver="" cd_only=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --hou) want_hou=1; [[ -n "${2-}" && "${2:0:2}" != "--" ]] && { ver="$2"; shift; } ;;
      --hou=*) want_hou=1; ver="${1#--hou=}";;
      --cd-only) cd_only=1;;
      *) echo "pkg: unknown flag '$1'"; return 1;;
    esac
    shift
  done

  local root
  root="$(_pkg_resolve_root "$target")" || { echo "pkg: not found → $target"; return 1; }
  local name="${root:t}"

  # Ensure Poetry uses SideFX Python for *this* project if requested or defaulted
  if (( want_hou )) || _pkg_is_houdini_pkg "$name"; then
    if (( want_hou )); then
      HOU_PROJECT_ROOT="$root" hou use "${ver:-latest}" || return 1
    else
      HOU_PROJECT_ROOT="$root" hou use latest || return 1
    fi
  fi

  cd "$root" || return 1
  (( cd_only )) && { pwd; return 0; }

  if ! _pkg_poetry_activate "$root"; then
    echo "pkg: no Poetry env yet → running 'poetry install'..."
    poetry install || return 1
    _pkg_poetry_activate "$root" || return 1
  fi

  echo "→ $(print -P "%F{cyan}${name}%f") active $(print -P "%F{8}[${PWD}]%f")"
}

# mkpkg: make a quick wrapper function (persist by adding the line to orbit later)
mkpkg() {
  emulate -L zsh
  if [[ -z "$1" ]]; then
    echo "Usage: mkpkg <name|path> [--hou [VER]] [--alias NAME]"; return 1
  fi
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

  eval "
${name}() { pkg ${(q)root} ${houflag}; }
"
  echo "→ Defined function: ${name}  (calls: pkg ${(q)root} ${houflag})"
}
