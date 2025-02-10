#!/bin/bash

# Function to load environment variables from a .env file
load_env_variables() {
  local env_file="$BASE_DIR/envars/.env"
  if [[ -f "$env_file" ]]; then
    while IFS='=' read -r key value; do
      # Skip comments and empty lines
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      # Expand variables dynamically if they contain '$'
      value=$(eval echo "$value")
      export "$key=$value"
    done < "$env_file" || {
      echo "Warning: Failed to load environment variables from $env_file." >&2
    }
  else
    echo "Warning: .env file not found in $BASE_DIR/envars." >&2
  fi
}

# Function to detect the operating system and set the $DROPBOX variable
set_dropbox_path() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export DROPBOX="$HOME/Dropbox"
  else
    echo "Warning: Unsupported operating system. Cannot set DROPBOX." >&2
  fi
}

set_docker_path() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export DOCKER="$HOME/Library/CloudStorage/Dropbox/matrix/docker"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export DOCKER="$HOME/Dropbox/matrix/docker"
  else
    echo "Warning: Unsupported operating system. Cannot set DOCKER." >&2
  fi
}

set_datalib_path() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export DATALIB="$HOME/Synology-dataLib"
  else
    echo "Warning: Unsupported operating system. Cannot set DATALIB." >&2
  fi
}


# Function to detect and set the base directory dynamically
set_base_dir() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -d "$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts" ]]; then
      export BASE_DIR="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts"
    elif [[ -d "$HOME/Documents/tools/cliUtils" ]]; then
      export BASE_DIR="$HOME/Documents/tools/cliUtils"
    else
      echo "Warning: Could not determine BASE_DIR on macOS." >&2
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -d "$HOME/Dropbox/matrix/shellscripts" ]]; then
      export BASE_DIR="$HOME/Dropbox/matrix/shellscripts"
    else
      echo "Warning: Could not determine BASE_DIR on Linux." >&2
    fi
  else
    echo "Warning: Unsupported operating system." >&2
  fi
}

# Ensure the credentials path is set and validate the credentials script
check_credentials_path() {
  if [[ -z "$CREDENTIALS_PATH" ]]; then
    echo "Warning: CREDENTIALS_PATH is not set. Ensure it is defined in the .env file or set manually." >&2
  else
    # Check if the credentials script exists
    local credentials_script="$CREDENTIALS_PATH/1PassCLI.sh"
    if [[ ! -f "$credentials_script" ]]; then
      echo "Warning: Credentials script not found at $credentials_script. Ensure the script exists." >&2
    else
      # Source the credentials script if it exists
      source "$credentials_script"
    fi
  fi
}

# Initialize setup without exiting on error
set_dropbox_path
set_docker_path
set_base_dir
load_env_variables
check_credentials_path
