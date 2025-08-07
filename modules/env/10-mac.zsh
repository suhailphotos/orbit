# modules/env/10-mac.zsh
[[ $ORBIT_PLATFORM == mac ]] || return

# pyenv + poetry on macOS
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && orbit_prepend_path "$PYENV_ROOT/bin"
command -v pyenv >/dev/null && eval "$(pyenv init -)"
# poetry usually via pipx (already added ~/.local/bin globally)

