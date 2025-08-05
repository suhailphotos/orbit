# modules/env/00-global.zsh

orbit_prepend_path "$HOME/.local/bin"   # pipx installs, etc.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export MATRIX="$DROPBOX/matrix"
export BASE_DIR="$MATRIX/shellscripts"
