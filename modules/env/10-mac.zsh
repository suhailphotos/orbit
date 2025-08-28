# modules/env/10-mac.zsh
[[ $ORBIT_PLATFORM == mac ]] || return

# Homebrew first (Apple Silicon + Intel), but only once
if [[ -z ${HOMEBREW_PREFIX-} ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# pyenv + poetry on macOS
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && orbit_prepend_path "$PYENV_ROOT/bin"
command -v pyenv >/dev/null && eval "$(pyenv init -)"
# poetry usually via pipx (already added ~/.local/bin globally)

# TERM safety (same pattern as linux)
if [[ -o interactive ]]; then
  if ! infocmp "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
  fi
fi


# --- Neovim light/dark hint for remote hosts (mac client only) ---
# You can force with:  NVIM_BG_FORCE=light|dark
if [[ -z "${NVIM_BG_FORCE-}" ]]; then
  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
    export NVIM_BG=dark
  else
    export NVIM_BG=light
  fi
else
  export NVIM_BG="$NVIM_BG_FORCE"
fi
