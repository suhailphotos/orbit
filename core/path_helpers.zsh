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

# Deduplicate PATH once per shell. Keeps first occurrence of each existing dir.
dedupe_path() {
  emulate -L zsh
  setopt extended_glob
  local -A seen
  local out=()
  local IFS=:
  for dir in $PATH; do
    [[ -n $dir && -d $dir && -z ${seen[$dir]} ]] && { out+="$dir"; seen[$dir]=1; }
  done
  PATH="${(j/:/)out}"
}
