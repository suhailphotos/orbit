# Nebula-AI mount and sub-paths (exists everywhere, value depends on platform)
case "$ORBIT_PLATFORM" in
  mac)   root="/Volumes/ai" ;;
  linux) root="/mnt/ai"     ;;
  wsl)   root="Z:/ai"       ;;
  *)     root="$HOME/ai"    ;;
esac

if [[ -d $root ]]; then
  export NEBULA_AI_ROOT="$root"  NEBULA_AI_MOUNTED=1
  for p in models datasets experiments logs scripts projects; do
    export "NEBULA_AI_${(U)p}"="$root/$p"
  done
else
  export NEBULA_AI_ROOT="" NEBULA_AI_MOUNTED=0
fi
