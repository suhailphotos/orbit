# modules/env/05-terminfo.zsh
# Ensure custom terminfo (~/.terminfo) is usable everywhere.

# Put per-user db first
case ":${TERMINFO_DIRS:-}:" in
  *":$HOME/.terminfo:"*) ;;
  *) export TERMINFO_DIRS="$HOME/.terminfo:${TERMINFO_DIRS:-/usr/share/terminfo}" ;;
esac

if command -v infocmp >/dev/null 2>&1 && command -v tic >/dev/null 2>&1; then
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    mkdir -p "$HOME/.terminfo"

    # 1) macOS: compile Ghostty’s bundled terminfo if present
    if [[ ${ORBIT_PLATFORM:-} == mac && "$TERM" == xterm-ghostty ]]; then
      _ghost_src="/Applications/Ghostty.app/Contents/Resources/terminfo/ghostty.ti"
      if [[ -r "$_ghost_src" ]]; then
        /usr/bin/tic -x -o "$HOME/.terminfo" "$_ghost_src" 2>/dev/null || true
      fi
    fi

    # 2) Optional repo copy: ORBIT_HOME/assets/terminfo/<TERM>.ti
    _repo_src="${ORBIT_HOME:-$HOME/.orbit}/assets/terminfo/${TERM}.ti"
    if [[ -r "$_repo_src" ]]; then
      tic -x -o "$HOME/.terminfo" "$_repo_src" 2>/dev/null || true
    fi

    # 3) Last resort: self-dump if the host knows it via another db
    _tmp="$(mktemp 2>/dev/null || mktemp -t ti 2>/dev/null)"
    if [[ -n "$_tmp" ]] && infocmp -x "$TERM" >| "$_tmp" 2>/dev/null; then
      tic -x -o "$HOME/.terminfo" "$_tmp" 2>/dev/null || true
    fi
    [[ -n ${_tmp-} ]] && rm -f "$_tmp"; unset _tmp _ghost_src _repo_src
  fi
fi
