# modules/env/18-fzf.zsh
# Lightweight fzf integration for Zsh via Orbit

# Only in interactive shells
[[ $- != *i* ]] && return

# Only if fzf exists
command -v fzf >/dev/null 2>&1 || return

# Find Homebrew / .fzf install paths
if command -v brew >/dev/null 2>&1; then
  local fzf_prefix
  fzf_prefix="$(brew --prefix fzf 2>/dev/null)"
  FZF_COMPLETION="${fzf_prefix}/shell/completion.zsh"
  FZF_BINDINGS="${fzf_prefix}/shell/key-bindings.zsh"
else
  FZF_COMPLETION="$HOME/.fzf/shell/completion.zsh"
  FZF_BINDINGS="$HOME/.fzf/shell/key-bindings.zsh"
fi

# Optional: completions
[[ -r "$FZF_COMPLETION" ]] && source "$FZF_COMPLETION"

# Keybindings: Ctrl-T, Ctrl-R, Alt-C, etc.
[[ -r "$FZF_BINDINGS" ]] && source "$FZF_BINDINGS"
