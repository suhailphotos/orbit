# Add Cargo's bin to PATH if present (works with or without CARGO_HOME)
for d in "${CARGO_HOME:-$HOME/.cargo}/bin" "$HOME/.cargo/bin"; do
  [[ -d $d ]] && orbit_prepend_path "$d" && break
done
