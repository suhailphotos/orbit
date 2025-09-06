# modules/env/16-search.zsh
# One ignore file to rule them all → rg, fd, Telescope

: ${XDG_CONFIG_HOME:="$HOME/.config"}

# ripgrep: point at your config file (which itself points at the shared ignore)
_rgrc="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
[[ -r "$_rgrc" ]] && export RIPGREP_CONFIG_PATH="$_rgrc"

# fd: use FD_OPTIONS (no special quoting needed; path has no spaces)
_ignore="$XDG_CONFIG_HOME/search/ignore"
[[ -r "$_ignore" ]] && export FD_OPTIONS="--hidden --ignore-file=$_ignore"

unset _rgrc _ignore
