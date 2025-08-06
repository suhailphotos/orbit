# core/path_helpers.zsh
####################################
# 1. Safe PATH prepend
orbit_prepend_path() {
  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
}

####################################
# 2. Simple .env loader (no prints)
orbit_load_dotenv() {
  local file=$1
  [[ -f $file ]] || return
  while IFS='=' read -r k v; do
    [[ $k =~ ^# || -z $k ]] && continue
    eval v=\"${v}\"
    export "$k"="$v"
  done <"$file"
}

# Export helpers to child shells **silently**
typeset -g -fx orbit_prepend_path orbit_load_dotenv
