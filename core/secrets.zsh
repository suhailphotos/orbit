# core/secrets.zsh  ────────────────────────────────────────────────
# Loads secrets for Orbit:
#   1. orbit/secrets/.env             ← highest priority
#   2. 1Password CLI (`op`)           ← if CLI + token available
#   3. nothing (print a warning)

########################################
# Helpers
########################################
_orbit_op_available()  { command -v op >/dev/null 2>&1 }
_orbit_die()           { print -P "%F{red}orbit:%f $*" >&2 }

# Ensure OP_* vars so that `op` is usable.
_orbit_prepare_op() {
  [[ -n $OP_SERVICE_ACCOUNT_TOKEN ]] && return         # already exported

  # Try a token file in secrets/
  local token_file="$ORBIT_HOME/secrets/op_token"
  if [[ -f $token_file ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN="$(<"$token_file")"
  fi

  # Always turn on CLI cache unless the user overrode it.
  export OP_CACHE="${OP_CACHE:-true}"
}

########################################
# Main loader
########################################
_orbit_load_secrets() {
  local envfile="$ORBIT_HOME/secrets/.env"
  local template="$ORBIT_HOME/secrets/.env.template"

  # --- 1. Load .env if present -------------------------------------
  if [[ -f $envfile ]]; then
    orbit_load_dotenv "$envfile"
  fi

  # --- 2. 1Password fills gaps ------------------------------------
  if _orbit_op_available; then
    _orbit_prepare_op
    if [[ -z $OP_SERVICE_ACCOUNT_TOKEN ]]; then
      _orbit_die "1Password token missing (set OP_SERVICE_ACCOUNT_TOKEN or secrets/op_token)."
      return
    fi

    # Export any key that is *still unset* after .env
    if [[ -f $template ]]; then
      while IFS='=' read -r k _; do
        [[ -z $k || $k == \#* ]] && continue
    #    [[ -z ${!k} ]] && export "$k"="$(op read "op://Personal/$k" 2>/dev/null || true)"
      done <"$template"
    fi
    return
  fi

  # --- 3. Nothing worked ------------------------------------------
  _orbit_die "No secrets loaded: .env missing and 1Password CLI not available."
}

_orbit_load_secrets
