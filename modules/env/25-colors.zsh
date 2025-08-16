# modules/env/25-colors.zsh
# Minimal color setup; prefer eza, fall back gracefully.

export LESS='-R'
export PAGER="${PAGER:-less}"

: ${ORBIT_USE_EZA:=1}   # 1 = prefer eza, 0 = use ls/gls
: ${ORBIT_LS_ICONS:=0}  # 1 = show icons with eza

# Point eza at your theme; keep defaults otherwise
export EZA_CONFIG_DIR="${EZA_CONFIG_DIR:-$HOME/.config/eza}"
export EZA_THEME="${EZA_THEME:-custom}"   # use $EZA_CONFIG_DIR/theme.yml when present
unset EZA_COLORS                          # don't let legacy color maps override YAML
# leave LS_COLORS alone so non-eza tools can still use it

_have_eza=0
if (( ORBIT_USE_EZA )) && command -v eza >/dev/null 2>&1; then
  _have_eza=1
  _eza_icons="" ; (( ORBIT_LS_ICONS )) && _eza_icons=" --icons=auto"
  _eza_common="--group-directories-first${_eza_icons}"

  alias ls="eza ${_eza_common}"
  alias ll="eza -lah ${_eza_common}"
  alias la="eza -la ${_eza_common}"
  alias tree="eza --tree ${_eza_common}"
fi

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

# grep colors
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
  alias egrep='ggrep -E --color=auto'
  alias fgrep='ggrep -F --color=auto'
elif grep --help 2>&1 | command grep -q -- '--color'; then
  alias grep='grep --color=auto'
  alias egrep='grep -E --color=auto'
  alias fgrep='grep -F --color=auto'
fi

# mac shims for GNU sed/awk (optional)
if [[ $ORBIT_PLATFORM == mac ]]; then
  command -v gsed >/dev/null 2>&1 && alias sed='gsed'
  command -v gawk >/dev/null 2>&1 && alias awk='gawk'
fi
