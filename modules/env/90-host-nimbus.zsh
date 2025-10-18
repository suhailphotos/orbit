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

# --- Auto-activate conda base on interactive shells (nimbus only) ---
# Respect a manual opt-out: ORBIT_NO_CONDA_AUTO=1
if [[ -o interactive && "${ORBIT_NO_CONDA_AUTO:-0}" -ne 1 ]]; then
  if command -v conda >/dev/null 2>&1; then
    # Only if no conda env is already active
    if [[ "${CONDA_SHLVL:-0}" -eq 0 ]]; then
      conda activate base 2>/dev/null || true
    fi
  fi
fi

unset _conda_roots _root

# --- Remote Mac paths (only if reachable over SSH) ---
# These are *remote* specs you can pass to scp/rsync or use in helpers.
# Example:  rsync -av somefile "$macnotes/"
if ssh -o BatchMode=yes -o ConnectTimeout=1 quasar 'test -d "$HOME/Documents"' >/dev/null 2>&1; then
  export macdocs='quasar:~/Documents'

  if ssh -o BatchMode=yes -o ConnectTimeout=1 quasar 'test -d "$HOME/Documents/Scratch/notes"' >/dev/null 2>&1; then
    export macnotes='quasar:~/Documents/Scratch/notes'
  fi

  if ssh -o BatchMode=yes -o ConnectTimeout=1 quasar 'test -d "$HOME/Documents/Scratch/exports"' >/dev/null 2>&1; then
    export macexports='quasar:~/Documents/Scratch/exports'
  fi
fi

# Optional: reuse 'projexp' name on Linux when Mac is reachable
if [[ -n ${macexports-} ]]; then
  export projexp="$macexports"
fi
