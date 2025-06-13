#!/usr/bin/env bash
# setup_env.sh — safe to source from zsh/bash, cross-platform

# 1) XDG config (if unset, default to ~/.config)
set_xdg_config() {
  : "${XDG_CONFIG_HOME:=$HOME/.config}"
  export XDG_CONFIG_HOME
}

# 2) Dropbox root
set_dropbox_path() {
  case "$OSTYPE" in
    darwin*)      DROPBOX="$HOME/Library/CloudStorage/Dropbox"    ;;
    linux-gnu*)   DROPBOX="$HOME/Dropbox"                        ;;
    msys*|cygwin*) DROPBOX="$USERPROFILE/Dropbox"                ;;
    *)            DROPBOX="$HOME/Dropbox"                       ;;
  esac
  export DROPBOX
}

# 3) Global .env file
set_global_env() {
  case "$OSTYPE" in
    darwin*)      GLOBAL_ENV_FILE="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts/envars/.env"    ;;
    linux-gnu*)   GLOBAL_ENV_FILE="$HOME/Dropbox/matrix/shellscripts/envars/.env"                        ;;
    msys*|cygwin*) GLOBAL_ENV_FILE="$USERPROFILE/Dropbox/matrix/shellscripts/envars/.env"                ;;
    *)            GLOBAL_ENV_FILE="$HOME/Dropbox/matrix/shellscripts/envars/.env"                       ;;
  esac
  export GLOBAL_ENV_FILE
}

# 4) Docker path (always under Dropbox)
set_docker_path() {
  DOCKER="$DROPBOX/matrix/docker"
  export DOCKER
}

# 5) DataLib path (SynologyDrive-dataLib lives in CloudStorage on mac, home on Linux/Windows)
set_datalib_path() {
  case "$OSTYPE" in
    darwin*)      DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib" ;;
    linux-gnu*)   DATALIB="/mnt/dataLib"                         ;;
    msys*|cygwin*) DATALIB="$USERPROFILE/Synology-dataLib"                 ;;
    *)            DATALIB="$HOME/Synology-dataLib"                        ;;
  esac
  export DATALIB
}

# 6) 
set_ml4vfx_path() {
  case "$OSTYPE" in
    darwin*)      ML4VFX="$HOME/Library/CloudStorage/SynologyDrive-dataLib/threeD/courses/05_Machine_Learning_in_VFX" ;;
    linux-gnu*)   ML4VFX="/mnt/dataLib/threeD/courses/05_Machine_Learning_in_VFX"                         ;;
    msys*|cygwin*) ML4VFX="$USERPROFILE/Synology-dataLib/threeD/courses/05_Machine_Learning_in_VFX"                 ;;
    *)            ML4VFX="$HOME/Synology-dataLib/threeD/courses/05_Machine_Learning_in_VFX"                        ;;
  esac
  export ML4VFX
}

# 7) BASE_DIR detection (where your shellscripts live)
set_base_dir() {
  if [[ -d "$DROPBOX/matrix/shellscripts" ]]; then
    BASE_DIR="$DROPBOX/matrix/shellscripts"
  elif [[ -d "$HOME/Documents/tools/cliUtils" ]]; then
    BASE_DIR="$HOME/Documents/tools/cliUtils"
  else
    BASE_DIR="$PWD"
  fi
  export BASE_DIR
}

# 8) Load .env from $BASE_DIR/envars/.env (skip blank/comment, support '=' in values)
load_env_variables() {
  local env_file="$BASE_DIR/envars/.env"
  if [[ -f "$env_file" ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue   # skip comments
      [[ -z "${line// }" ]] && continue            # skip blank
      key=${line%%=*}
      val=${line#*=}
      eval val=\"${val}\"                          # expand embedded vars
      export "$key"="$val"
    done <"$env_file"
  else
    echo "Warning: .env not found at $env_file" >&2
  fi
}

# 9) Source credentials helper if CREDENTIALS_PATH is defined
source_credentials() {
  if [[ -n "${CREDENTIALS_PATH-}" ]]; then
    local cred_script
    case "$OSTYPE" in
      msys*|cygwin*) cred_script="$CREDENTIALS_PATH/1PassCLI.bat" ;;
      *)             cred_script="$CREDENTIALS_PATH/1PassCLI.sh"  ;;
    esac

    if [[ -f "$cred_script" ]]; then
      source "$cred_script"
    else
      echo "Warning: Credentials script not found at $cred_script" >&2
    fi
  fi
}


# 10) Houdini User Pref (macOS only; grabs latest SideFX install)
set_houdini_user_pref_dir() {
  if [[ "$OSTYPE" == darwin* ]]; then
    local latest_version
    latest_version=$(ls -d /Applications/Houdini/Houdini* 2>/dev/null | \
      sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1)
    if [[ -n "$latest_version" ]]; then
      export HOUDINI_USER_PREF_DIR="$HOME/Library/Preferences/houdini/${latest_version%.*}"
    else
      export HOUDINI_USER_PREF_DIR="$HOME/Library/Preferences/houdini"
      echo "Warning: Could not find a Houdini install in /Applications/Houdini." >&2
    fi
  fi
}

# 11) Obsidian path (Obsidian vault path on Dropbox, home on Linux/Windows)
set_obsedian_path() {
  case "$OSTYPE" in
    darwin*)      OBSIDIAN="$HOME/Library/CloudStorage/Dropbox/matrix/obsidian/jnanaKosha" ;;
    linux-gnu*)   OBSIDIAN="$HOME/Dropbox/matrix/obsidian/jnanaKosha"                         ;;
    msys*|cygwin*) OBSIDIAN="$USERPROFILE/Dropbox/matrix/obsidian/jnanaKosha"                 ;;
    *)            OBSIDIAN="$HOME/Dropbox/matrix/obsidian/jnanaKosha"                        ;;
  esac
  export OBSIDIAN
}

set_nebula_ai_paths() {
  case "$OSTYPE" in
    darwin*)   # macOS
      if [[ -d "/Volumes/ai" ]]; then
        export NEBULA_AI_ROOT="/Volumes/ai"
        export NEBULA_AI_MOUNTED=1
      else
        export NEBULA_AI_ROOT=""
        export NEBULA_AI_MOUNTED=0
        echo "Warning: Nebula AI share /Volumes/ai not mounted." >&2
      fi
      ;;
    linux-gnu*)   # Ubuntu/Linux VM
      export NEBULA_AI_ROOT="/mnt/ai"
      export NEBULA_AI_MOUNTED=1
      ;;
    msys*|cygwin*) # Windows (WSL, etc.)
      export NEBULA_AI_ROOT="Z:/ai"
      export NEBULA_AI_MOUNTED=1
      ;;
    *)
      export NEBULA_AI_ROOT="$HOME/ai"
      export NEBULA_AI_MOUNTED=0
      ;;
  esac

  if [[ -n "$NEBULA_AI_ROOT" && -d "$NEBULA_AI_ROOT" ]]; then
    export NEBULA_AI_MODELS="$NEBULA_AI_ROOT/models"
    export NEBULA_AI_DATASETS="$NEBULA_AI_ROOT/datasets"
    export NEBULA_AI_EXPERIMENTS="$NEBULA_AI_ROOT/experiments"
    export NEBULA_AI_LOGS="$NEBULA_AI_ROOT/logs"
    export NEBULA_AI_SCRIPTS="$NEBULA_AI_ROOT/scripts"
    export NEBULA_AI_PROJECTS="$NEBULA_AI_ROOT/projects"
  else
    export NEBULA_AI_MODELS=""
    export NEBULA_AI_DATASETS=""
    export NEBULA_AI_EXPERIMENTS=""
    export NEBULA_AI_LOGS=""
    export NEBULA_AI_SCRIPTS=""
    export NEBULA_AI_PROJECTS=""
  fi
}


# 11) Main initializer
main() {
  set_xdg_config
  set_dropbox_path
  set_global_env
  set_docker_path
  set_datalib_path
  set_ml4vfx_path
  set_base_dir
  set_houdini_user_pref_dir
  load_env_variables
  source_credentials
  set_obsedian_path
  set_nebula_ai_paths
}

# Run it
main
