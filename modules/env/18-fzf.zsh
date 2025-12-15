# modules/env/18-fzf.zsh
emulate -L zsh

[[ $- != *i* ]] && return
command -v fzf >/dev/null 2>&1 || return

if command -v brew >/dev/null 2>&1; then
  local fzf_prefix
  fzf_prefix="$(brew --prefix fzf 2>/dev/null)"
  FZF_COMPLETION="${fzf_prefix}/shell/completion.zsh"
  FZF_BINDINGS="${fzf_prefix}/shell/key-bindings.zsh"
else
  FZF_COMPLETION="$HOME/.fzf/shell/completion.zsh"
  FZF_BINDINGS="$HOME/.fzf/shell/key-bindings.zsh"
fi

# Optional: completions (quiet)
if [[ -r "$FZF_COMPLETION" ]]; then
  if ! { source "$FZF_COMPLETION" } >/dev/null 2>&1; then
    print -u2 -- "[orbit] fzf completion failed to load: $FZF_COMPLETION"
  fi
else
  print -u2 -- "[orbit] fzf completion not found: $FZF_COMPLETION"
fi

# Keybindings (quiet)
if [[ -r "$FZF_BINDINGS" ]]; then
  if ! { source "$FZF_BINDINGS" } >/dev/null 2>&1; then
    print -u2 -- "[orbit] fzf key-bindings failed to load: $FZF_BINDINGS"
  fi
else
  print -u2 -- "[orbit] fzf key-bindings not found: $FZF_BINDINGS"
fi
