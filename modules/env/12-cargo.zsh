# Add Cargo's bin to PATH if present (works with or without CARGO_HOME)
for d in "${CARGO_HOME:-$HOME/.cargo}/bin" "$HOME/.cargo/bin"; do
  [[ -d $d ]] && orbit_prepend_path "$d" && break
done

# Keep Cargo build artifacts out of Dropbox (and out of repos).
# Can be overridden in a host file, e.g., modules/env/90-host-nimbus.zsh
: ${CARGO_TARGET_DIR:="$HOME/.cache/cargo/targets"}
export CARGO_TARGET_DIR
mkdir -p "$CARGO_TARGET_DIR" 2>/dev/null || true
