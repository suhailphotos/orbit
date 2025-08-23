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
