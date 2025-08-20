# Only on 'flicker'
[[ $ORBIT_HOST == flicker ]] || return

# Cargo (only if installed)
orbit_prepend_path "$HOME/.cargo/bin"
