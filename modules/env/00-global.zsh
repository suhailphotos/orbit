# modules/env/00-global.zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export GLOBAL_ENV_FILE="$ORBIT_HOME/secrets/.env"

# Global editors: prefer Neovim, then Vim, then vi
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim VISUAL=nvim GIT_EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim  VISUAL=vim  GIT_EDITOR=vim
else
  export EDITOR=vi   VISUAL=vi   GIT_EDITOR=vi
fi

# common CLI paths
orbit_prepend_path "$HOME/.local/bin"   # pipx etc
