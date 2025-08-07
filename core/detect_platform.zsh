# Sets $ORBIT_PLATFORM  → mac / linux / wsl / other
case "$OSTYPE" in
  darwin*)    ORBIT_PLATFORM=mac   ;;
  linux-gnu*) ORBIT_PLATFORM=linux ;;
  msys*|cyg*) ORBIT_PLATFORM=wsl   ;;
  *)          ORBIT_PLATFORM=other ;;
esac
export ORBIT_PLATFORM

# Also record host (for host-specific env like CUDA/Conda)
ORBIT_HOST="${ORBIT_HOST:-$(hostname -s 2>/dev/null || hostname)}"
export ORBIT_HOST
