# modules/env/50-icloud-linux.zsh
# Linux-wide wiring to mount a Mac's Documents (incl. Scratch/exports) over SSHFS.

# Only run on Linux / WSL
[[ $ORBIT_PLATFORM == linux || $ORBIT_PLATFORM == wsl ]] || return 0

# Optional global kill switch
[[ "${ORBIT_ICLOUD_ENABLE:-1}" == 0 ]] && return 0

# --------------------------------------------------------------------
# 1) Generic config (overridable per host via env)
# --------------------------------------------------------------------

# SSH host alias for the current Mac (defined in ~/.ssh/config).
# Override per-machine if needed:
#   export ORBIT_ICLOUD_HOST="new-mac-host"
: "${ORBIT_ICLOUD_HOST:=quasar}"

# Remote path *relative to the Mac's $HOME*
# This becomes $HOME/Documents on the Mac side.
: "${ORBIT_ICLOUD_REMOTE_PATH:=Documents}"

# Identity to use for SSH (override if a box uses a different key)
: "${ORBIT_ICLOUD_IDENTITY:=$HOME/.ssh/id_quasar}"

# Local mount root on the Linux side
: "${ORBIT_ICLOUD_MOUNT_ROOT:=$HOME/icloudDocs}"

# What the rest of your tooling should use:
# projexp → icloudDocs/Scratch/exports (once mounted)
export projexp="${ORBIT_ICLOUD_MOUNT_ROOT}/Scratch/exports"

# Ensure the mount root exists (no output, ignore errors)
mkdir -p "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || true

# --------------------------------------------------------------------
# 2) Helpers to mount / unmount (no auto-mount at startup)
# --------------------------------------------------------------------

mount_icloudDocs() {
  # If sshfs isn't installed, silently fail
  if ! command -v sshfs >/dev/null 2>&1; then
    return 1
  fi

  # Already mounted? Success, nothing to do.
  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    return 0
  fi

  sshfs "${ORBIT_ICLOUD_HOST}:${ORBIT_ICLOUD_REMOTE_PATH}" \
        "${ORBIT_ICLOUD_MOUNT_ROOT}" \
        -o IdentityFile="${ORBIT_ICLOUD_IDENTITY}" \
        -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
        >/dev/null 2>&1

  # If mount now shows up, treat as success; otherwise fail silently
  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    return 0
  else
    return 1
  fi
}

unmount_icloudDocs() {
  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    fusermount -u "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || \
      umount "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || true
  fi
}
