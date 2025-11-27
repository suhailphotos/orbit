# modules/env/18-fzf.zsh

# Debug: see if this file even runs
echo "[orbit:fzf] loading 18-fzf.zsh (shell flags: $-)" >&2

# Only in interactive shells
if [[ $- != *i* ]]; then
  echo "[orbit:fzf] non-interactive shell, skipping" >&2
  return
fi

# Need fzf
if ! command -v fzf >/dev/null 2>&1; then
  echo "[orbit:fzf] fzf not found in \$PATH, skipping" >&2
  return
fi

# Try Homebrew path first
if command -v brew >/dev/null 2>&1; then
  FZF_BINDINGS="$(brew --prefix fzf)/shell/key-bindings.zsh"
else
  FZF_BINDINGS="$HOME/.fzf/shell/key-bindings.zsh"
fi

echo "[orbit:fzf] candidate key-bindings: $FZF_BINDINGS" >&2

if [[ -r "$FZF_BINDINGS" ]]; then
  echo "[orbit:fzf] sourcing: $FZF_BINDINGS" >&2
  source "$FZF_BINDINGS"
else
  echo "[orbit:fzf] key-bindings.zsh not found or not readable" >&2
fi
