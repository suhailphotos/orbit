# modules/env/32-pixi.zsh
export PIXI_HOME="${PIXI_HOME:-$HOME/.pixi}"
orbit_prepend_path "$PIXI_HOME/bin"

# Optional: pick a feature name based on OS for your single manifest
case "$ORBIT_PLATFORM" in
  mac)   export PIXI_GLOBAL_FEATURES="mac"   ;;
  linux) export PIXI_GLOBAL_FEATURES="linux" ;;
  *)     export PIXI_GLOBAL_FEATURES=""      ;;
esac
