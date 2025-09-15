# modules/env/32-pixi.zsh — Pixi path + host-manifest helpers (Bindu/Stow design)
# Only define anything if Pixi is installed.

# detect presence without exporting anything yet
_pixi_home="${PIXI_HOME:-$HOME/.pixi}"
_pixi_present=0
if command -v pixi >/dev/null 2>&1; then
  _pixi_present=1
elif [[ -x "$_pixi_home/bin/pixi" ]]; then
  _pixi_present=1
fi
(( _pixi_present )) || return

# Now and only now, export Pixi-related vars / PATH
if [[ -d "$_pixi_home" ]]; then
  export PIXI_HOME="$_pixi_home"
fi
[[ -d "${PIXI_HOME:-$_pixi_home}/bin" ]] && orbit_prepend_path "${PIXI_HOME:-$_pixi_home}/bin"

# Optional OS hint for *your* scripts (Pixi itself doesn’t read this)
case "$ORBIT_PLATFORM" in
  mac)   export PIXI_GLOBAL_FEATURES="mac"   ;;
  linux) export PIXI_GLOBAL_FEATURES="linux" ;;
  *)     unset PIXI_GLOBAL_FEATURES ;;  # don’t define it at all on unknowns
esac

# Shell-only paths (defined only when Pixi is present)
PIXIH_HOST_TRACKED="${PIXIH_HOST_TRACKED:-$XDG_CONFIG_HOME/pixi/hosts/${ORBIT_HOST}/.pixi/manifests/pixi-global.toml}"
PIXIH_LIVE_LINK="${PIXIH_LIVE_LINK:-${PIXI_HOME:-$_pixi_home}/manifests/pixi-global.toml}"

# If the live link isn’t present, hint how to link with Stow (no auto-linking)
if [[ ! -e "$PIXIH_LIVE_LINK" ]]; then
  mkdir -p "${PIXIH_LIVE_LINK:h}"
  if [[ -o interactive && -t 1 ]]; then
    print -P "%F{8}pixi:%f missing live manifest link → run: %Bstow -d $XDG_CONFIG_HOME/pixi/hosts -t $HOME -R ${ORBIT_HOST}%b"
  fi
fi

# QoL helpers (only exist when Pixi is present)
alias pxg='${=EDITOR:-nvim} "$PIXIH_HOST_TRACKED"'
pxg_sync() { pixi global sync; }
pxg_list() { pixi global list; }
pxg_host() { echo "$PIXIH_HOST_TRACKED"; }
pxg_live() { echo "$PIXIH_LIVE_LINK"; }

# cleanup locals
unset _pixi_home _pixi_present
