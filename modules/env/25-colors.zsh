# modules/env/25-colors.zsh
# Unified, minimal color config for common CLIs. No OMZ required.

# Allow ANSI colors to pass through pagers
export LESS='-R'
export PAGER="${PAGER:-less}"

# ---- feature toggles (override in host/env if you like) ----
: ${ORBIT_USE_EZA:=1}     # 1 = prefer eza when available, 0 = use ls/gls
: ${ORBIT_LS_ICONS:=0}    # 1 = show icons with eza, 0 = no icons (default)

_have_eza=0
if (( ORBIT_USE_EZA )) && command -v eza >/dev/null 2>&1; then
  _have_eza=1

  # Make sure a theme (if present) is honored:
  # EZA_COLORS / LS_COLORS override theme.yml, so clear them when using eza.
  unset EZA_COLORS LS_COLORS   # keep theme.yml effective

  _eza_icons="" ; (( ORBIT_LS_ICONS )) && _eza_icons=" --icons=auto"
  _eza_common="--group-directories-first --hyperlink=never${_eza_icons}"

  alias ls="eza ${_eza_common}"
  alias ll="eza -lah ${_eza_common}"
  alias la="eza -la ${_eza_common}"
  alias tree="eza --tree ${_eza_common}"
fi

# eza theme
export EZA_CONFIG_DIR="${EZA_CONFIG_DIR:-$HOME/.config/eza}"
if [[ ! -f "$EZA_CONFIG_DIR/theme.yml" ]]; then
  mkdir -p "$EZA_CONFIG_DIR"
  cat > "$EZA_CONFIG_DIR/theme.yml" <<'YML'
# Minimal starter: remove underline from README(.md) and all *.md
filenames:
  "README":        { filename: { is_underline: false, foreground: Cyan, is_bold: true } }
  "README.md":     { filename: { is_underline: false, foreground: Cyan, is_bold: true } }

extensions:
  "md":            { filename: { is_underline: false, foreground: Cyan } }
YML
fi

# If we don't have (or don't want) eza, keep your colored ls/tree setup
if (( !_have_eza )); then
  case "$ORBIT_PLATFORM" in
    mac)
      if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto --group-directories-first'
        alias ll='gls -lah --color=auto --group-directories-first'
        alias la='gls -A --color=auto --group-directories-first'
      else
        export CLICOLOR=1
        export LSCOLORS="${LSCOLORS:-Gxfxcxdxbxegedabagacad}"
        alias ls='ls -G'
        alias ll='ls -lah'
        alias la='ls -A'
      fi
      alias tree='tree -C'
      ;;
    linux)
      command -v dircolors >/dev/null 2>&1 && eval "$(dircolors -b)"
      alias ls='ls --color=auto'
      alias ll='ls -lah --color=auto'
      alias la='ls -A --color=auto'
      alias tree='tree -C'
      ;;
  esac
fi

# bat instead of cat (Debian names it batcat)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
fi

# Color grep (prefer GNU if present, else fallback to --color=auto if supported)
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
  alias egrep='ggrep -E --color=auto'
  alias fgrep='ggrep -F --color=auto'
elif grep --help 2>&1 | command grep -q -- '--color'; then
  alias grep='grep --color=auto'
  alias egrep='grep -E --color=auto'
  alias fgrep='grep -F --color=auto'
fi
# Optional GREP_COLORS:
# export GREP_COLORS='ms=01;31:mc=01;31:fn=35:ln=32:bn=32:se=36'

# Color diff: prefer delta (great with git), else colordiff if installed
if command -v delta >/dev/null 2>&1; then
  export GIT_PAGER='delta'
  export DELTA_FEATURES='line-numbers decorations'
elif command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff'
fi

# mac-specific shims for GNU sed/awk (independent of eza/ls choice)
if [[ $ORBIT_PLATFORM == mac ]]; then
  command -v gsed  >/dev/null 2>&1 && alias sed='gsed'
  command -v gawk  >/dev/null 2>&1 && alias awk='gawk'
  # Optional: GNU find/xargs
  # command -v gfind  >/dev/null 2>&1 && alias find='gfind'
  # command -v gxargs >/dev/null 2>&1 && alias xargs='gxargs'
fi

# Ripgrep/fd already colorize by default.
# Ensure terminal supports colors:
#   echo $TERM   (expect xterm-256color) ; tput colors
