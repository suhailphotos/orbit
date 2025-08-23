# core/path_helpers.zsh
########################################

orbit_prepend_path() {
  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
}

orbit_load_dotenv() {
  local file=$1; [[ -f $file ]] || return
  while IFS='=' read -r k v; do
    [[ $k =~ ^# || -z $k ]] && continue
    eval v=\"${v}\"
    if [[ $v == op://* ]]; then
      _orbit_prepare_op
      v="$(op read "$v" 2>/dev/null || true)"
    fi
    export "$k"="$v"
  done <"$file"
}

