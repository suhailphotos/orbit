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

    # Compile from Orbit’s asset if present (works even if Ghostty isn't installed)
    _repo_src="${ORBIT_HOME:-$HOME/.orbit}/assets/terminfo/${TERM}.ti"
    [[ -r "$_repo_src" ]] && tic -x -o "$HOME/.terminfo" "$_repo_src" 2>/dev/null || true

    # Last resort: self-dump if some db knows it
    _tmp="$(mktemp 2>/dev/null || mktemp -t ti 2>/dev/null)"
    if [[ -n "$_tmp" ]] && infocmp -x "$TERM" >| "$_tmp" 2>/dev/null; then
      tic -x -o "$HOME/.terminfo" "$_tmp" 2>/dev/null || true
    fi
    [[ -n ${_tmp-} ]] && rm -f "$_tmp"; unset _tmp _repo_src
  fi
fi
