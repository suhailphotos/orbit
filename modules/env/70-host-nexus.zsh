# Only on 'nexus'
[[ $ORBIT_HOST == nexus ]] || return

# Cargo (only if installed)
orbit_prepend_path "$HOME/.cargo/bin"
