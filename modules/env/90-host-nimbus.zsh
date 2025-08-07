# Host-specific: only on 'nimbus' load CUDA/Conda (and mark to use Conda in venv funcs)
[[ $ORBIT_HOST == nimbus ]] || return

export ORBIT_USE_CONDA=1

# CUDA (only on this host)
export CUDA_HOME="/usr/local/cuda"
orbit_prepend_path "$CUDA_HOME/bin"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH}"

# Conda hook
if [[ -x "$HOME/anaconda3/bin/conda" ]]; then
  __conda_setup="$("$HOME/anaconda3/bin/conda" shell.zsh hook 2>/dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__conda_setup"
  elif [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/anaconda3/bin:$PATH"
  fi
  unset __conda_setup
fi
