# modules/env/16-search.zsh
# One ignore file to rule them all → rg, fd, Telescope

# Respect XDG; fall back to ~/.config if not set
: ${XDG_CONFIG_HOME:="$HOME/.config"}

# Point ripgrep at your config (which points to the shared ignore)
_rgrc="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
if [[ -r "$_rgrc" ]]; then
  export RIPGREP_CONFIG_PATH="$_rgrc"
fi

# fd doesn’t have a config file; use FD_OPTIONS
_ignore="$XDG_CONFIG_HOME/search/ignore"
if [[ -r "$_ignore" ]]; then
  # Keep it minimal so you can still add flags ad hoc at the CLI
  export FD_OPTIONS="--hidden --ignore-file=$(_ignore:q)"
fi
unset _rgrc _ignore
