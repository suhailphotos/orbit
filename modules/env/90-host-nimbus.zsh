# modules/env/90-host-nimbus.zsh
[[ $ORBIT_HOST == nimbus ]] || return

orbit_prepend_path "$HOME/.cargo/bin"

# If you want Starship on nimbus once installed, set it here.
# Comment out to keep automatic selection.
export ORBIT_PROMPT=${ORBIT_PROMPT:-auto}

# Prefer Conda on this host (venv functions look at this flag)
export ORBIT_USE_CONDA=1


# --- CUDA (only if present) ---
CUDA_HOME_DEFAULT="/usr/local/cuda"
if [[ -d "$CUDA_HOME_DEFAULT" ]]; then
  export CUDA_HOME="$CUDA_HOME_DEFAULT"
  orbit_prepend_path "$CUDA_HOME/bin"

  # Safe LD_LIBRARY_PATH append (no trailing colon if empty)
  if [[ -n "${LD_LIBRARY_PATH:-}" ]]; then
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
  else
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64"
  fi
fi

# --- Conda: support miniconda/anaconda/mambaforge and use official hook if available ---
_conda_roots=(
  "$HOME/miniconda3"
  "$HOME/anaconda3"
  "$HOME/mambaforge"
  "$HOME/micromamba"  # if you ever symlink micromamba to look like conda
)
for _root in "${_conda_roots[@]}"; do
  if [[ -x "$_root/bin/conda" ]]; then
    # Use conda's shell hook when possible
    __conda_setup="$("$_root/bin/conda" shell.zsh hook 2>/dev/null)" || __conda_setup=""
    if [[ -n "$__conda_setup" ]]; then
      eval "$__conda_setup"
    elif [[ -f "$_root/etc/profile.d/conda.sh" ]]; then
      . "$_root/etc/profile.d/conda.sh"
    else
      export PATH="$_root/bin:$PATH"
    fi
    unset __conda_setup
    break
  fi
done

unset _conda_roots _root

# --- Remote Mac paths (no probing at login) ---
export macdocs='quasar:~/Documents'
export macnotes='quasar:~/Documents/Scratch/notes'
export macexports='quasar:~/Documents/Scratch/exports'

# If you ever want a quick “is it there?” check, run:
orbit_mac_check() {
  local ok=0
  ssh -o BatchMode=yes -o ConnectTimeout=1 quasar 'true' >/dev/null 2>&1 && ok=1
  (( ok )) && echo "quasar reachable" || echo "quasar unreachable"
}
