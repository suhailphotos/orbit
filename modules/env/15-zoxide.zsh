# modules/env/15-zoxide.zsh
# Initialize zoxide only if available, and only for interactive shells.

[[ -o interactive ]] || return 0
: ${ORBIT_USE_ZOXIDE:=1}   # allow hosts to opt out

if (( ORBIT_USE_ZOXIDE )) && command -v zoxide >/dev/null 2>&1; then
  # Use `cd` as the command (your preference). If you’d rather keep builtin cd,
  # change to:  eval "$(zoxide init zsh)"  and use `z`/`zi` etc.
  eval "$(zoxide init zsh --cmd cd)"
fi
