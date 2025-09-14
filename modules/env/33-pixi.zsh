# 33-pixi.zsh — light-touch Pixi helpers, no heavy work at init
# Prefer env var override; default to ~/.pixi
: ${ORBIT_PIXI_HOME:="$HOME/.pixi"}
if [[ -d "$ORBIT_PIXI_HOME/bin" ]]; then
  orbit_prepend_path "$ORBIT_PIXI_HOME/bin"
fi
# Respect installer’s PATH (pixi adds ~/.pixi/bin), do nothing if missing
command -v pixi >/dev/null 2>&1 || return

# Where your tracked manifest lives (bindu)
: ${ORBIT_PIXI_GLOBAL_TRACKED:="$XDG_CONFIG_HOME/pixi/global/pixi-global.toml"}
# Where Pixi expects it
: ${ORBIT_PIXI_GLOBAL_LINK:="$HOME/.pixi/manifests/pixi-global.toml"}

# One-time bootstrap: create the symlink if missing
orbit_pixi_link_manifest() {
  [[ -r "$ORBIT_PIXI_GLOBAL_TRACKED" ]] || { echo "pixi manifest missing: $ORBIT_PIXI_GLOBAL_TRACKED"; return 1; }
  mkdir -p "${ORBIT_PIXI_GLOBAL_LINK:h}"
  ln -sf "$ORBIT_PIXI_GLOBAL_TRACKED" "$ORBIT_PIXI_GLOBAL_LINK"
  echo "→ Linked Pixi global manifest."
}

# Convenient wrappers
alias pxg='${=EDITOR:-nvim} "$ORBIT_PIXI_GLOBAL_TRACKED"'
pxg_sync() { pixi global sync; }
pxg_list() { pixi global list; }

# Optional: link automatically if the link is missing (cheap)
[[ -e "$ORBIT_PIXI_GLOBAL_LINK" ]] || orbit_pixi_link_manifest
