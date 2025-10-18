# core/path_helpers.zsh
########################################

#orbit_prepend_path() {
#  [[ -d $1 ]] && PATH="$1:${PATH:#$1(:|)}"
#}

orbit_prepend_path() {
  local dir="$1"
  [[ -d $dir ]] || return
  path=($dir ${path:#$dir})
}

orbit_append_path() {
  local dir="$1"
  [[ -d $dir ]] || return
  path=(${path:#$dir} $dir)
}

orbit_load_dotenv() {
  local file=$1; [[ -f $file ]] || return
  local k v
  while IFS='=' read -r k v || [[ -n $k ]]; do
    [[ $k == \#* || -z $k ]] && continue
    eval v=\"${v}\"
    export "$k=$v"
    if [[ $v == op://* ]]; then
      typeset -ga ORBIT_SECRET_KEYS
      ORBIT_SECRET_KEYS+=("$k")
    fi
  done <"$file"
}

