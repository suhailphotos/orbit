# modules/env/25-colors.zsh
# Minimal color setup; prefer eza, fall back gracefully.

export LESS='-R'
export PAGER="${PAGER:-less}"

# ---- feature toggles (override per host if you like) ----
: ${ORBIT_USE_EZA:=1}        # 1 = prefer eza, 0 = use ls/gls
: ${ORBIT_LS_ICONS:=0}       # 1 = show icons with eza
: ${ORBIT_DOTFILES_SGR:=90}  # SGR for dotfiles when using eza (90 = bright black)

# Point eza at your theme directory; eza auto-loads $EZA_CONFIG_DIR/theme.yml if present.
export EZA_CONFIG_DIR="${EZA_CONFIG_DIR:-$HOME/.config/eza}"
# Do NOT set EZA_THEME unless you use a non-default filename.
# Leave LS_COLORS alone so non-eza tools can still use it.
unset EZA_COLORS   # ensure theme.yml (if any) isn't overridden globally

_have_eza=0
# ----- eza aliases with dotfile/dotdir dimming (overrides theme.yml) -----
if (( ORBIT_USE_EZA )) && command -v eza >/dev/null 2>&1; then
  _have_eza=1
  _eza_icons="" ; (( ORBIT_LS_ICONS )) && _eza_icons=" --icons=auto"
  _eza_common="--group-directories-first${_eza_icons}"

  # Styles (ANSI SGR codes)
  : ${ORBIT_DOT_STYLE:='90;2'}      # bright-black + dim for ALL dotfiles/dirs
  : ${ORBIT_README_STYLE:='0;36;1'} # reset + cyan + bold (no underline)
  : ${ORBIT_MD_STYLE:='0;36'}       # reset + cyan for *.md (optional)

  # Optional per-name overrides (colon-separated EZA_COLORS pairs)
  : ${ORBIT_DOT_OVERRIDES:=''}      # e.g. ".git=90;2:.github=90;2"

  # Build the EZA_COLORS string (order matters: later entries win)
  _eza_colors=".*=${ORBIT_DOT_STYLE}:README=${ORBIT_README_STYLE}:README.md=${ORBIT_README_STYLE}:*.md=${ORBIT_MD_STYLE}"
  [[ -n "${ORBIT_DOT_OVERRIDES}" ]] && _eza_colors="${_eza_colors}:${ORBIT_DOT_OVERRIDES}"

  alias ls="EZA_COLORS='${_eza_colors}' eza ${_eza_common}"
  alias la="EZA_COLORS='${_eza_colors}' eza -la ${_eza_common}"
  alias ll="EZA_COLORS='${_eza_colors}' eza -lah ${_eza_common}"
  alias tree="EZA_COLORS='${_eza_colors}' eza --tree ${_eza_common}"
fi

# Fallback when eza isn't available
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

# bat > cat (optional)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
fi

# grep colors (prefer Homebrew GNU on macOS if present)
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
  alias egrep='ggrep -E --color=auto'
  alias fgrep='ggrep -F --color=auto'
elif grep --help 2>&1 | command grep -q -- '--color'; then
  alias grep='grep --color=auto'
  alias egrep='grep -E --color=auto'
  alias fgrep='grep -F --color=auto'
fi

# mac shims for GNU sed/awk (independent of eza/ls choice)
if [[ $ORBIT_PLATFORM == mac ]]; then
  command -v gsed  >/dev/null 2>&1 && alias sed='gsed'
  command -v gawk  >/dev/null 2>&1 && alias awk='gawk'
  # Optional: GNU find/xargs
  # command -v gfind  >/dev/null 2>&1 && alias find='gfind'
  # command -v gxargs >/dev/null 2>&1 && alias xargs='gxargs'
fi
