# modules/env/20-paths.zsh  ───────────────────────────────
# General paths that never contain secrets
orbit_prepend_path "$HOME/.local/bin"

# Dropbox & Matrix
case "$ORBIT_PLATFORM" in
  mac)   export DROPBOX="$HOME/Library/CloudStorage/Dropbox" ;;
  linux) export DROPBOX="$HOME/Dropbox"                     ;;
  wsl)   export DROPBOX="$USERPROFILE/Dropbox"              ;;
  *)     export DROPBOX="$HOME/Dropbox"                     ;;
esac
export MATRIX="$DROPBOX/matrix"
export DOCKER="$MATRIX/docker"

# Synology data library
case "$ORBIT_PLATFORM" in
  mac)   export DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib" ;;
  linux) export DATALIB="/mnt/dataLib"                                     ;;
  wsl)   export DATALIB="$USERPROFILE/Synology-dataLib"                    ;;
  *)     export DATALIB="$HOME/Synology-dataLib"                           ;;
esac
export ML4VFX="$DATALIB/threeD/courses/05_Machine_Learning_in_VFX"

# Obsidian vault
export OBSIDIAN="$MATRIX/obsidian/jnanaKosha"
