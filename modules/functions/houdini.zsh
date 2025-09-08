# modules/functions/houdini.zsh
# Generic Houdini helpers for Poetry projects (no hard-coded package names).
# macOS + Linux supported. Nothing heavy runs on shell init.

# If Houdini isn't installed (per detect_apps), provide a stub and exit quietly
if [[ "${ORBIT_HAS_HOUDINI:-0}" != 1 ]]; then
  hou() { echo "Houdini not detected on this host."; return 1; }
  return
fi

# ---------------------------
# Internals (helpers)
# ---------------------------

# Find project root (walk up until we find pyproject.toml)
_hou_project_root() {
  local d="${1:-$PWD}"
  while [[ "$d" != "/" ]]; do
    [[ -f "$d/pyproject.toml" ]] && { echo "$d"; return 0; }
    d="${d:h}"
  done
  return 1
}

# Read a simple TOML string key from [tool.poetry] (name/version etc.)
# Usage: _hou_toml_get <key> [file]
_hou_toml_get() {
  local key="$1" file="${2:-pyproject.toml}"
  [[ -r "$file" ]] || return 1
  sed -nE "0,/^\[tool\.poetry\]/ s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]+)\".*/\1/p" "$file" | head -n1
}

# List installed Houdini versions (sorted new→old), return as lines like 21.0.440
_hou_versions() {
  if [[ $ORBIT_PLATFORM == mac ]]; then
    ls -1d /Applications/Houdini/Houdini* 2>/dev/null \
      | sed 's|.*/Houdini||' \
      | sort -Vr
  elif [[ $ORBIT_PLATFORM == linux ]]; then
    # Prefer /opt/hfsX.Y.ZZZ (matches detect_apps)
    ls -1d /opt/hfs* 2>/dev/null \
      | sed 's|.*/hfs||' \
      | sort -Vr
  fi
}

# Pick a version: explicit arg or "latest installed" fallback
_hou_pick_version() {
  local want="$1"
  if [[ -n "$want" ]]; then
    echo "$want"
    return 0
  fi
  # fallback to detected version from detect_apps first
  if [[ -n "${ORBIT_HOUDINI_VERSION:-}" ]]; then
    echo "$ORBIT_HOUDINI_VERSION"
    return 0
  fi
  # otherwise scan filesystem
  _hou_versions | head -n1
}

# Compute important paths for a given version.
# Prints KEY=VALUE lines:
#   VER=21.0.440
#   RES=/Applications/.../Resources            (mac)
#   HFS=/opt/hfs21.0.440 or ...                (linux or from houdini_setup)
#   PYBIN=/absolute/path/to/Houdini Python     (for "poetry env use")
_hou_paths() {
  local ver="$1"
  local RES="" HFS="" PYBIN=""

  if [[ $ORBIT_PLATFORM == mac ]]; then
    local root="/Applications/Houdini/Houdini${ver}"
    RES="$root/Frameworks/Houdini.framework/Versions/Current/Resources"
    # SideFX bundled Python (stable path)
    PYBIN="$root/Frameworks/Houdini.framework/Versions/Current/Resources/Frameworks/Python.framework/Versions/Current/bin/python3"
    HFS="$root/Frameworks/Houdini.framework/Versions/Current"
    [[ -x "$PYBIN" && -d "$RES" ]] || return 1
  else
    # Linux: standard install layout
    HFS="/opt/hfs${ver}"
    [[ -d "$HFS" ]] || return 1
    # pick matching python in $HFS/bin (try common versions)
    for py in "$HFS/bin/python3.11" "$HFS/bin/python3.10" "$HFS/bin/python3"; do
      [[ -x "$py" ]] && PYBIN="$py" && break
    done
    [[ -n "$PYBIN" ]] || return 1
    RES="$HFS"  # houdini_setup is at $HFS/houdini_setup
  fi

  print -r -- "VER=$ver"
  print -r -- "RES=$RES"
  print -r -- "HFS=$HFS"
  print -r -- "PYBIN=$PYBIN"
}

# Resolve Houdini user pref dir for X.Y (major.minor)
_hou_pref_dir_for_version() {
  local ver="$1"
  local mm="${ver%.*}"
  case "$ORBIT_PLATFORM" in
    mac)   echo "$HOME/Library/Preferences/houdini/$mm" ;;
    linux) echo "$HOME/houdini$mm" ;;
    wsl)   echo "$HOME/Documents/houdini$mm" ;;
    *)     echo "$HOME/houdini$mm" ;;
  esac
}

# Return Poetry venv path for a project (without activating)
_hou_poetry_env_path() {
  local proj_root="$1"
  (cd "$proj_root" && poetry env info --path 2>/dev/null) || return 1
}

# Return site-packages for that venv (asks venv’s python)
_hou_site_packages() {
  local venv="$1"
  [[ -x "$venv/bin/python" ]] || return 1
  "$venv/bin/python" - "$@" <<'PY'
import site, sys, sysconfig
# prefer purelib (site-packages) from sysconfig
paths = sysconfig.get_paths()
pure = paths.get("purelib")
if pure:
    print(pure)
else:
    s = site.getsitepackages()
    print(s[0] if s else site.getusersitepackages())
PY
}

# Source houdini_setup into *this* shell (so HFS/HHP etc. are set)
_hou_source_setup() {
  local RES="$1" HFS="$2"
  if [[ $ORBIT_PLATFORM == mac ]]; then
    # mac: houdini_setup lives under Resources
    [[ -r "$RES/houdini_setup" ]] || { echo "Missing $RES/houdini_setup"; return 1; }
    # shellcheck disable=SC1090
    source "$RES/houdini_setup"
  else
    [[ -r "$HFS/houdini_setup" ]] || { echo "Missing $HFS/houdini_setup"; return 1; }
    # shellcheck disable=SC1090
    source "$HFS/houdini_setup"
  fi
}

# Write/patch $HOUDINI_USER_PREF_DIR/houdini.env with a PYTHONPATH entry (idempotent).
_hou_patch_houdini_env() {
  local prefdir="$1" site="$2"
  mkdir -p "$prefdir"
  local envfile="$prefdir/houdini.env"
  touch "$envfile"
  if ! grep -qF "$site" "$envfile"; then
    printf 'PYTHONPATH="$PYTHONPATH:%s"\n' "$site" >>"$envfile"
    echo "→ Added site-packages to $envfile"
  else
    echo "→ Site-packages already present in $envfile"
  fi
}

# Tiny “import hou” smoke test using the SideFX python (after houdini_setup)
_hou_smoke_import() {
  local pybin="$1"
  local license="${2:-}" release="${3:-0}"
  local extra=""
  [[ -n "$license" ]] && extra="import os; os.environ['HOUDINI_SCRIPT_LICENSE'] = '${license}'; "
  "$pybin" - <<PY || return 1
${extra}import hou
print("hou ok:", hou.applicationVersionString())
${release:+hou.releaseLicense()}
PY
}

# ---------------------------
# Public command: hou
# ---------------------------
# Subcommands:
#   hou versions                    # list installed versions (new→old)
#   hou python  [VER|latest]        # print SideFX python path for version
#   hou prefs   [VER|latest]        # export HOUDINI_USER_PREF_DIR for version (in-shell)
#   hou use     [VER|latest]        # from a Poetry project dir: set interpreter to SideFX python
#   hou patch   [VER|latest]        # add project’s site-packages to houdini.env
#   hou import  [VER|latest] [--license hescape|batch] [--release]  # smoke-test import hou
#   hou env     [VER|latest]        # source houdini_setup into this shell (no python run)
#   hou doctor  [VER|latest]        # show resolved paths & quick checks
#
# Notes:
# - Run "hou use" *inside* your package folder (auto-detects pyproject name).
# - If you prefer specifying the package root, set HOU_PROJECT_ROOT before calling.
# - "latest" is the default when no version is given.
hou() {
  emulate -L zsh
  setopt pipefail no_unset

  local cmd="${1:-help}"; shift || true
  local req_ver="${1:-}"; [[ -n "$req_ver" && "$cmd" != "python" && "$cmd" != "prefs" && "$cmd" != "use" && "$cmd" != "patch" && "$cmd" != "import" && "$cmd" != "env" && "$cmd" != "doctor" ]] && req_ver=""
  [[ -n "$req_ver" && "$req_ver" != "latest" ]] && shift || true

  case "$cmd" in
    versions)
      _hou_versions || { echo "No Houdini versions found." >&2; return 1; }
      return 0
      ;;
    python|prefs|use|patch|import|env|doctor)
      local ver; ver="$(_hou_pick_version "${req_ver:-}")" || { echo "Couldn’t resolve Houdini version."; return 1; }
      local kv; kv="$(_hou_paths "$ver")" || { echo "Couldn’t resolve paths for $ver"; return 1; }
      local RES HFS PYBIN; eval "$kv"    # set RES/HFS/PYBIN

      case "$cmd" in
        python)
          echo "$PYBIN"
          ;;

        prefs)
          local pref; pref="$(_hou_pref_dir_for_version "$ver")"
          export HOUDINI_USER_PREF_DIR="$pref"
          mkdir -p "$HOUDINI_USER_PREF_DIR"
          echo "HOUDINI_USER_PREF_DIR=$HOUDINI_USER_PREF_DIR"
          ;;

        use)
          local proj_root="${HOU_PROJECT_ROOT:-$(_hou_project_root)}"
          [[ -n "$proj_root" ]] || { echo "Not inside a Poetry project (pyproject.toml not found)."; return 1; }
          (cd "$proj_root" && poetry env use "$PYBIN") || return 1
          echo "Poetry env for $(basename "$proj_root") → $PYBIN"
          ;;

        patch)
          local proj_root="${HOU_PROJECT_ROOT:-$(_hou_project_root)}"
          [[ -n "$proj_root" ]] || { echo "Not inside a Poetry project (pyproject.toml not found)."; return 1; }
          local pref; pref="$(_hou_pref_dir_for_version "$ver")"
          export HOUDINI_USER_PREF_DIR="$pref"
          mkdir -p "$pref"

          local venv; venv="$(_hou_poetry_env_path "$proj_root")" || { echo "Poetry env not found."; return 1; }
          local site; site="$(_hou_site_packages "$venv")"       || { echo "Couldn’t locate site-packages."; return 1; }

          _hou_patch_houdini_env "$pref" "$site"
          ;;

        import)
          # flags: --license hescape|batch, --release
          local license="" release=0 arg
          for arg in "$@"; do
            case "$arg" in
              --license) shift; license="$1"; shift || true ;;
              --license=*) license="${arg#--license=}" ;;
              --release) release=1 ;;
            esac
          done

          _hou_source_setup "$RES" "$HFS" || return 1
          # lightweight: only set prefs if user asked earlier; otherwise skip
          _hou_smoke_import "$PYBIN" "$license" "$release"
          ;;

        env)
          _hou_source_setup "$RES" "$HFS"
          echo "houdini_setup sourced for $ver (HFS=$HFS)"
          ;;

        doctor)
          echo "Resolved:"
          echo "  Version : $ver"
          echo "  RES     : $RES"
          echo "  HFS     : $HFS"
          echo "  PYBIN   : $PYBIN"
          if _hou_source_setup "$RES" "$HFS" >/dev/null 2>&1; then
            echo "  setup   : OK (houdini_setup)"
          else
            echo "  setup   : FAILED"
          fi
          ;;

      esac
      ;;

    help|*)
      cat <<'EOF'
hou — SideFX/Houdini helpers for Poetry projects

Usage:
  hou versions
  hou python  [VER|latest]
  hou prefs   [VER|latest]
  hou use     [VER|latest]                # run inside a Poetry project dir
  hou patch   [VER|latest]                # add project site-packages to houdini.env
  hou import  [VER|latest] [--license hescape|batch] [--release]
  hou env     [VER|latest]
  hou doctor  [VER|latest]

Tips:
- Run "hou use" inside your package folder (auto-detects pyproject).
- Omit VER to use the newest installed Houdini.
- "hou import" is heavy (initializes Houdini & checks out a license); it's optional.
- To target a specific project outside CWD: HOU_PROJECT_ROOT=/path/to/pkg hou use
EOF
      ;;
  esac
}
