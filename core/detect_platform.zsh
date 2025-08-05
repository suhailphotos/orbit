# Sets $ORBIT_PLATFORM  → mac / linux / wsl / other
case "$OSTYPE" in
  darwin*)    ORBIT_PLATFORM=mac   ;;
  linux-gnu*) ORBIT_PLATFORM=linux ;;
  msys*|cyg*) ORBIT_PLATFORM=wsl   ;;
  *)          ORBIT_PLATFORM=other ;;
esac
export ORBIT_PLATFORM
