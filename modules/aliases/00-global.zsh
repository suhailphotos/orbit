# modules/aliases/00-global.zsh — sourced by Zsh (not executable)

# --------------------------------------------------
# Conditional aliases & functions
# --------------------------------------------------
# Use Neovim by default when available; keep a hard fallback
if command -v nvim >/dev/null 2>&1; then
  alias nv='nvim'
  vi() { nvim "$@"; }   # Option B feel: typing 'vi' opens Neovim
fi

# Force stock Vim/vi even when debugging Neovim
vix() {
  if command -v vim >/dev/null 2>&1; then command vim "$@"
  elif command -v vi  >/dev/null 2>&1; then command vi  "$@"
  else echo "No stock vi/vim found." >&2; return 1
  fi
}

# --------------------------------------------------
# Direct aliases
# --------------------------------------------------
alias orbit='cd $DROPBOX/matrix/orbit'
alias bindu='cd $XDG_CONFIG_HOME'
alias helix='cd $DROPBOX/matrix/helix'
alias lilac='cd $DROPBOX/matrix/lilac'
alias mira='cd $DROPBOX/matrix/mira'
alias tessera='cd $DROPBOX/matrix/tessera'
alias packages='cd $DROPBOX/matrix/packages'
alias crates='cd $DROPBOX/matrix/crates'
alias truss='cd $DROPBOX/matrix/truss'
alias matrix='cd $DROPBOX/matrix'
alias apogee='cd $DROPBOX/matrix/crates/apogee'
alias atrium='cd $DROPBOX/matrix/atrium'
alias swivel='cd $DROBOX/matrix/swibel'
alias lg='lazygit'
alias gs='git status'
