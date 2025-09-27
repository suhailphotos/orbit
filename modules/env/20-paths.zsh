# modules/env/20-paths.zsh  ───────────────────────────────
# Global vars (exist on all machines) with platform-specific values.

# Dropbox
case "$ORBIT_PLATFORM" in
  mac)   export DROPBOX="$HOME/Library/CloudStorage/Dropbox" ;;
  linux) export DROPBOX="$HOME/Dropbox"                      ;;
  wsl)   export DROPBOX="$USERPROFILE/Dropbox"               ;;
  *)     export DROPBOX="$HOME/Dropbox"                      ;;
esac

# Matrix & common roots
export MATRIX="$DROPBOX/matrix"
export DOCKER="$MATRIX/docker"
export BASE_DIR="$MATRIX/shellscripts"
export PACKAGES="$MATRIX/packages"
export CRATES="$MATRIX/crates"

# Synology data library
case "$ORBIT_PLATFORM" in
  mac)   export DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib" ;;
  linux) export DATALIB="/mnt/dataLib"                                     ;;
  wsl)   export DATALIB="$USERPROFILE/Synology-dataLib"                    ;;
  *)     export DATALIB="$HOME/Synology-dataLib"                           ;;
esac

# ML4VFX course
export ML4VFX="$DATALIB/threeD/courses/05_Machine_Learning_in_VFX"

# Obsidian vault
export OBSIDIAN="$MATRIX/obsidian/jnanaKosha"
