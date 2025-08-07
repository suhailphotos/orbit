# modules/env/00-global.zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export GLOBAL_ENV_FILE="$ORBIT_HOME/secrets/.env"

# common CLI paths
orbit_prepend_path "$HOME/.local/bin"   # pipx etc
