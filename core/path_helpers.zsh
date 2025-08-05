# Simple helper; we don’t actually need to export it.
orbit_prepend_path() {
  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
}
# If you ever *do* need it in child shells, use typeset – quiet:
# typeset -g -fx orbit_prepend_path
