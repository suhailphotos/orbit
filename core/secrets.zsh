# core/secrets.zsh
_orbit_op_available()  { command -v op >/dev/null 2>&1 }
_orbit_die()           { print -P "%F{red}orbit:%f $*" >&2 }

_orbit_prepare_op() {
  [[ -n $OP_SERVICE_ACCOUNT_TOKEN ]] && return
  local token_file="$ORBIT_HOME/secrets/op_token"
  [[ -f $token_file ]] && export OP_SERVICE_ACCOUNT_TOKEN="$(<"$token_file")"
  export OP_CACHE="${OP_CACHE:-true}"
}

_orbit_load_secrets() {
  local envfile="$ORBIT_HOME/secrets/.env"
  [[ -f $envfile ]] && orbit_load_dotenv "$envfile"

  if _orbit_op_available; then
    _orbit_prepare_op
    [[ -z $OP_SERVICE_ACCOUNT_TOKEN ]] && {
      _orbit_die "1Password token missing (set OP_SERVICE_ACCOUNT_TOKEN or secrets/op_token)."
      return
    }
    # If you want to auto-fill unset keys from a template, uncomment and adapt:
    # local template="$ORBIT_HOME/secrets/.env.template"
    # [[ -f $template ]] && while IFS='=' read -r k _; do
    #   [[ -z $k || $k == \#* ]] && continue
    #   [[ -z ${(!)k} ]] && export "$k"="$(op read "op://Personal/$k" 2>/dev/null || true)"
    # done <"$template"
    return
  fi

  _orbit_die "No secrets loaded: .env missing and 1Password CLI not available."
}

# --- Lazy 1Password resolution (first command only) --------------------------
_orbit_resolve_all_secrets() {
  (( ${#ORBIT_SECRET_KEYS[@]:-0} )) || return 0
  _orbit_op_available || return 0
  _orbit_prepare_op

  local k v resolved
  for k in "${ORBIT_SECRET_KEYS[@]}"; do
    v="${(P)k}"
    [[ $v == op://* ]] || continue
    resolved="$(op read "$v" 2>/dev/null || true)"
    [[ -n $resolved ]] && export "$k=$resolved"
  done
  ORBIT_SECRET_KEYS=()   # clear list once we’ve resolved
}

_orbit_resolve_secrets_once() {
  add-zsh-hook -d preexec _orbit_resolve_secrets_once
  _orbit_resolve_all_secrets
}

# Eager mode knob: set ORBIT_SECRETS_EAGER=1 to keep old behavior
if (( ${#ORBIT_SECRET_KEYS[@]:-0} )); then
  if [[ ${ORBIT_SECRETS_EAGER:-0} -eq 1 ]]; then
    _orbit_resolve_all_secrets
  else
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _orbit_resolve_secrets_once
  fi
fi

_orbit_load_secrets
