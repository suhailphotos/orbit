# modules/env/40-icloud-linux.zsh
# Linux-wide wiring to mount a Mac's Documents (incl. Scratch/exports) over SSHFS.

# Only run on Linux / WSL
[[ $ORBIT_PLATFORM == linux || $ORBIT_PLATFORM == wsl ]] || return 0

# Optional global kill switch
[[ "${ORBIT_ICLOUD_ENABLE:-1}" == 0 ]] && return 0

# --------------------------------------------------------------------
# 1) Generic config (overridable per host via env)
# --------------------------------------------------------------------

# SSH host alias for the current Mac (defined in ~/.ssh/config).
# You can override this per-machine:
#   export ORBIT_ICLOUD_HOST="new-mac-host"
: "${ORBIT_ICLOUD_HOST:=quasar}"

# Remote path *relative to the Mac's $HOME*
# This becomes:  $HOME/Documents  on the Mac side.
: "${ORBIT_ICLOUD_REMOTE_PATH:=Documents}"

# Identity to use for SSH (override if a box uses a different key)
: "${ORBIT_ICLOUD_IDENTITY:=$HOME/.ssh/id_quasar}"

# Local mount root on the Linux side
: "${ORBIT_ICLOUD_MOUNT_ROOT:=$HOME/icloudDocs}"

# This is what the rest of your tooling should use:
# projexp → icloudDocs/Scratch/exports (once mounted)
export projexp="${ORBIT_ICLOUD_MOUNT_ROOT}/Scratch/exports"

# Make sure the mount root exists (doesn't matter if nothing is mounted yet)
mkdir -p "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || true

# --------------------------------------------------------------------
# 2) Helpers to mount / unmount (no auto-mount at startup)
# --------------------------------------------------------------------

mount_icloudDocs() {
  # If sshfs isn't installed, just print a quiet hint and bail.
  if ! command -v sshfs >/dev/null 2>&1; then
    echo "mount_icloudDocs: sshfs not installed on this machine; skipping" >&2
    return 1
  fi

  # Already mounted?
  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    echo "iCloud already mounted at ${ORBIT_ICLOUD_MOUNT_ROOT}"
    return 0
  fi

  sshfs "${ORBIT_ICLOUD_HOST}:${ORBIT_ICLOUD_REMOTE_PATH}" \
        "${ORBIT_ICLOUD_MOUNT_ROOT}" \
        -o IdentityFile="${ORBIT_ICLOUD_IDENTITY}" \
        -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3

  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    echo "Mounted ${ORBIT_ICLOUD_HOST}:${ORBIT_ICLOUD_REMOTE_PATH} at ${ORBIT_ICLOUD_MOUNT_ROOT}"
    return 0
  else
    echo "mount_icloudDocs: sshfs failed (host unreachable? key missing?); leaving things as-is." >&2
    return 1
  end
}

unmount_icloudDocs() {
  if mount | grep -q "on ${ORBIT_ICLOUD_MOUNT_ROOT} "; then
    fusermount -u "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || \
      umount "${ORBIT_ICLOUD_MOUNT_ROOT}" 2>/dev/null || true
  fi
}
