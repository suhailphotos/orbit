# modules/functions/houdini.zsh  (UV version)
if [[ "${ORBIT_HAS_HOUDINI:-0}" != 1 ]]; then
  hou() { echo "Houdini not detected on this host."; return 1; }
  return
fi

_hou_project_root() {
  local d="${1:-$PWD}"
  while [[ "$d" != "/" ]]; do
    [[ -f "$d/pyproject.toml" ]] && { echo "$d"; return 0; }
    d="${d:h}"
  done; return 1
}
_hou_versions() {
  if [[ $ORBIT_PLATFORM == mac ]]; then
    ls -1d /Applications/Houdini/Houdini* 2>/dev/null \
      | sed 's|.*/Houdini||' | LC_ALL=C sort -t . -k1,1nr -k2,2nr -k3,3nr
  else
    ls -1d /opt/hfs* 2>/dev/null \
      | sed 's|.*/hfs||' | LC_ALL=C sort -t . -k1,1nr -k2,2nr -k3,3nr
  fi
}
_hou_pick_version() {
  local want="$1"
  [[ -n "$want" && "$want" != "latest" ]] && { echo "$want"; return 0; }
  [[ -n "${ORBIT_HOUDINI_VERSION:-}" ]] && { echo "$ORBIT_HOUDINI_VERSION"; return 0; }
  _hou_versions | head -n1
}
_hou_paths() {
  local ver="$1" RES="" HFS="" PYBIN=""
  if [[ $ORBIT_PLATFORM == mac ]]; then
    local root="/Applications/Houdini/Houdini${ver}"
    RES="$root/Frameworks/Houdini.framework/Versions/Current/Resources"
    PYBIN="$root/Frameworks/Houdini.framework/Versions/Current/Resources/Frameworks/Python.framework/Versions/Current/bin/python3"
    HFS="$root/Frameworks/Houdini.framework/Versions/Current"
    [[ -x "$PYBIN" && -d "$RES" ]] || return 1
  else
    HFS="/opt/hfs${ver}"
    [[ -d "$HFS" ]] || return 1
    for py in "$HFS/bin/python3.11" "$HFS/bin/python3.10" "$HFS/bin/python3"; do
      [[ -x "$py" ]] && PYBIN="$py" && break
    done
    [[ -n "$PYBIN" ]] || return 1
    RES="$HFS"
  fi
  print -r -- "VER=$ver"; print -r -- "RES=$RES"; print -r -- "HFS=$HFS"; print -r -- "PYBIN=$PYBIN"
}
_hou_pref_dir_for_version() {
  local ver="$1" mm="${ver%.*}"
  case "$ORBIT_PLATFORM" in
    mac)   echo "$HOME/Library/Preferences/houdini/$mm" ;;
    linux) echo "$HOME/houdini$mm" ;;
    wsl)   echo "$HOME/Documents/houdini$mm" ;;
    *)     echo "$HOME/houdini$mm" ;;
  esac
}
_hou_site_packages_for_venv() {
  local venv="$1"; [[ -x "$venv/bin/python" ]] || return 1
  "$venv/bin/python" - <<'PY'
import sysconfig; print(sysconfig.get_paths().get("purelib"))
PY
}
_hou_source_setup() {
  local RES="$1" HFS="$2"
  if [[ $ORBIT_PLATFORM == mac ]]; then
    [[ -r "$RES/houdini_setup" ]] || { echo "Missing $RES/houdini_setup"; return 1; }
    source "$RES/houdini_setup"
  else
    [[ -r "$HFS/houdini_setup" ]] || { echo "Missing $HFS/houdini_setup"; return 1; }
    source "$HFS/houdini_setup"
  fi
}
_hou_smoke_import() {
  local pybin="$1" license="${2:-}" release="${3:-0}" extra=""
  [[ -n "$license" ]] && extra="import os; os.environ['HOUDINI_SCRIPT_LICENSE'] = '${license}'; "
  "$pybin" - <<PY || return 1
${extra}import hou
print("hou ok:", hou.applicationVersionString())
${release:+hou.releaseLicense()}
PY
}
_hou_write_pkg_json() {
  local prefdir="$1" site="$2"
  mkdir -p "$prefdir/packages"
  cat >| "$prefdir/packages/98_uv_site.json" <<JSON
{
  "enable": true,
  "load_package_once": true,
  "env": [{ "PYTHONPATH": "\${PYTHONPATH}:${site}" }]
}
JSON
  echo "→ Wrote dev shim: $prefdir/packages/98_uv_site.json"
}

hou() {
  emulate -L zsh; setopt pipefail
  local cmd="${1:-help}"; shift || true
  local req_ver=""; case "${1-}" in latest|[0-9]*.[0-9]*.[0-9]*) req_ver="$1"; shift;; esac
  case "$cmd" in
    versions) _hou_versions || { echo "No Houdini versions found." >&2; return 1; } ;;
    python|prefs|use|patch|import|env|doctor)
      local ver; ver="$(_hou_pick_version "${req_ver:-}")" || { echo "Couldn’t resolve Houdini version."; return 1; }
      local kv; kv="$(_hou_paths "$ver")" || { echo "Couldn’t resolve paths for $ver"; return 1; }
      local RES HFS PYBIN; eval "$kv"
      case "$cmd" in
        python) echo "$PYBIN" ;;
        prefs)
          local pref; pref="$(_hou_pref_dir_for_version "$ver")"
          export HOUDINI_USER_PREF_DIR="$pref"; mkdir -p "$pref"
          echo "HOUDINI_USER_PREF_DIR=$HOUDINI_USER_PREF_DIR"
          ;;
        use)
          local proj_root="${HOU_PROJECT_ROOT:-$(_hou_project_root)}"
          [[ -n "$proj_root" ]] || { echo "Not inside a project (pyproject.toml not found)."; return 1; }
          cd "$proj_root" || return 1

          local envroot="${ORBIT_UV_VENV_ROOT:-$HOME/.venvs}/${proj_root:t}"
          export UV_PROJECT_ENVIRONMENT="$envroot"

          local q=""; (( ORBIT_UV_QUIET )) && q="-q"
          if [[ -x "$envroot/bin/python" ]]; then
            local cur_py; cur_py="$("$envroot/bin/python" -c 'import sys; print(sys.executable)')"
            if [[ "$cur_py" != "$PYBIN" ]]; then
              echo "Recreating env with SideFX Python…"
              rm -rf -- "$envroot"
              uv venv --python "$PYBIN" $q || return 1
              if [[ -f uv.lock ]]; then uv sync --frozen $q; else uv lock $q && uv sync $q; fi
            fi
          else
            uv venv --python "$PYBIN" $q || return 1
            if [[ -f uv.lock ]]; then uv sync --frozen $q; else uv lock $q && uv sync $q; fi
          fi

          source "$envroot/bin/activate"
          # (Intentionally ignores ORBIT_UV_QUIET so `hou use` is explicit.)
          print -r -- "hou use: interpreter → $PYBIN"
          ;;
        patch)
          local proj_root="${HOU_PROJECT_ROOT:-$(_hou_project_root)}"
          [[ -n "$proj_root" ]] || { echo "Not inside a project (pyproject.toml not found)."; return 1; }
          local envroot="${ORBIT_UV_VENV_ROOT:-$HOME/.venvs}/${proj_root:t}"
          local pref; pref="$(_hou_pref_dir_for_version "$ver")"
          export HOUDINI_USER_PREF_DIR="$pref"; mkdir -p "$pref"
          local site; site="$(_hou_site_packages_for_venv "$envroot")" || { echo "No env yet; run 'hou use' or 'uv venv' first."; return 1; }
          local envfile="$pref/houdini.env"; touch "$envfile"
          if ! grep -qF "$site" "$envfile"; then
            printf 'PYTHONPATH="$PYTHONPATH:%s"\n' "$site" >> "$envfile"
            echo "→ Added site-packages to $envfile"
          else
            echo "→ Site-packages already present in $envfile"
          fi
          ;;
        import)
          local license="" release=0 arg
          for arg in "$@"; do
            case "$arg" in
              --license) shift; license="${1:-}";;
              --license=*) license="${arg#--license=}";;
              --release) release=1;;
            esac
          done
          _hou_source_setup "$RES" "$HFS" || return 1
          _hou_smoke_import "$PYBIN" "$license" "$release"
          ;;
        env)
          _hou_source_setup "$RES" "$HFS" || return 1
          echo "houdini_setup sourced for $ver (HFS=$HFS)"
          ;;
        doctor)
          echo "Resolved:"; echo "  Version : $ver"; echo "  RES     : $RES"; echo "  HFS     : $HFS"; echo "  PYBIN   : $PYBIN"
          if _hou_source_setup "$RES" "$HFS" >/dev/null 2>&1; then echo "  setup   : OK (houdini_setup)"; else echo "  setup   : FAILED"; fi
          ;;
      esac
      ;;
    pkgshim)
      local ver; ver="$(_hou_pick_version "${req_ver:-}")" || { echo "Couldn’t resolve Houdini version."; return 1; }
      local kv; kv="$(_hou_paths "$ver")" || { echo "Couldn’t resolve paths for $ver"; return 1; }
      local RES HFS PYBIN; eval "$kv"
      local proj_root="${HOU_PROJECT_ROOT:-$(_hou_project_root)}"
      [[ -n "$proj_root" ]] || { echo "Not inside a project (pyproject.toml not found)."; return 1; }
      local envroot="${ORBIT_UV_VENV_ROOT:-$HOME/.venvs}/${proj_root:t}"
      local pref; pref="$(_hou_pref_dir_for_version "$ver")"
      export HOUDINI_USER_PREF_DIR="$pref"; mkdir -p "$pref"
      local site; site="$(_hou_site_packages_for_venv "$envroot")" || { echo "No env yet; run 'hou use' or 'uv venv' first."; return 1; }
      _hou_write_pkg_json "$pref" "$site"
      echo "Dev package shim ready (Houdini will pick it up next launch)."
      ;;
    help|*)
      cat <<'EOF'
hou — SideFX/Houdini helpers for uv projects

Usage:
  hou versions
  hou python  [VER|latest]
  hou prefs   [VER|latest]
  hou use     [VER|latest]                # create/recreate external uv env (~/.venvs/<project>) with SideFX python
  hou pkgshim [VER|latest]                # write user package JSON pointing to .venv
  hou patch   [VER|latest]                # (legacy) write houdini.env with site-packages
  hou import  [VER|latest] [--license hescape|batch] [--release]
  hou env     [VER|latest]
  hou doctor  [VER|latest]
EOF
      ;;
  esac
}
