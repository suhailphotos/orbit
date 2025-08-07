# modules/env/10-linux.zsh
[[ $ORBIT_PLATFORM == linux ]] || return
# Intentionally minimal.
# No CUDA/Conda here (machine-specific). Put those in 90-host-*.zsh.
