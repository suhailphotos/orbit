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
# Roots
# --------------------------------------------------
alias matrix='cd $DROPBOX/matrix'
alias packages='cd $PACKAGES'
alias crates='cd $CRATES'
alias bindu='cd $XDG_CONFIG_HOME'

# --------------------------------------------------
# Commands
# --------------------------------------------------
alias gs='git status'
alias lg='lazygit'

# --------------------------------------------------
# Projects
# --------------------------------------------------
alias orbit='cd $DROPBOX/matrix/orbit'
alias helix='cd $DROPBOX/matrix/helix'
alias tessera='cd $DROPBOX/matrix/tessera'
alias truss='cd $DROPBOX/matrix/truss'
alias iris='cd $DROPBOX/matrix/iris'
alias atrium='cd $DROPBOX/matrix/atrium'

# --------------------------------------------------
# Crates
# --------------------------------------------------
alias apogee='cd $DROPBOX/matrix/crates/apogee'
alias swivel='cd $DROPBOX/matrix/crates/swivel'
alias rillio='cd $DROPBOX/matrix/crates/rillio'
alias rusk='cd $DROPBOX/matrix/crates/rusk'

# --------------------------------------------------
# Neovim projects
# --------------------------------------------------
alias lilac='cd $DROPBOX/matrix/lilac'
alias mira='cd $DROPBOX/matrix/mira'
alias notio='cd $DROPBOX/matrix/nvim/notio'

