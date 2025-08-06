# modules/env/20-paths.zsh  ───────────────────────────────
# General paths that don't include secrets

# Docker root is always inside Dropbox
export DOCKER="$DROPBOX/matrix/docker"

# Synology-driven data library
case "$ORBIT_PLATFORM" in
  mac)   export DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib" ;;
  linux) export DATALIB="/mnt/dataLib"                                     ;;
  wsl)   export DATALIB="$USERPROFILE/Synology-dataLib"                    ;;
  *)     export DATALIB="$HOME/Synology-dataLib"                           ;;
esac

# Machine-learning course
export ML4VFX="$DATALIB/threeD/courses/05_Machine_Learning_in_VFX"

# Obsidian vault
case "$ORBIT_PLATFORM" in
  mac)   export OBSIDIAN="$DROPBOX/matrix/obsidian/jnanaKosha" ;;
  *)     export OBSIDIAN="$DROPBOX/matrix/obsidian/jnanaKosha" ;;
esac
