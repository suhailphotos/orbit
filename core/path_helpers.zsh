# core/path_helpers.zsh
orbit_prepend_path() {
  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
}

orbit_load_dotenv() {
  local file=$1; [[ -f $file ]] || return
  while IFS='=' read -r k v; do
    [[ $k =~ ^# || -z $k ]] && continue
    eval v=\"${v}\"
    export "$k"="$v"
  done <"$file"
}

# QUIET export to child shells (does NOT print)
typeset -g -fx orbit_prepend_path orbit_load_dotenv
