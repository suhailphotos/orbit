# Safely prepend to PATH without duplicates
orbit_prepend_path() {
  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
}
export -f orbit_prepend_path
