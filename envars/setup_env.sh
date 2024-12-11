#!/bin/bash

# Function to load environment variables from a .env file
load_env_variables() {
  local env_file="$BASE_DIR/envars/.env"
  if [[ -f "$env_file" ]]; then
    export $(grep -v '^#' "$env_file" | sed "s|\$DROPBOX|$DROPBOX|g" | xargs)
  else
    echo "Error: .env file not found in $BASE_DIR/envars." >&2
    return 1
  fi
}

# Function to detect the operating system and set the $DROPBOX variable
set_dropbox_path() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific setup
    export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific setup
    export DROPBOX="$HOME/Dropbox"
  else
    echo "Error: Unsupported operating system. Cannot set DROPBOX." >&2
    return 1
  fi
}

# Function to detect and set the base directory dynamically
set_base_dir() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific setup
    if [[ -d "$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts" ]]; then
      export BASE_DIR="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts"
    elif [[ -d "$HOME/Documents/tools/cliUtils" ]]; then
      export BASE_DIR="$HOME/Documents/tools/cliUtils"
    else
      echo "Error: Could not determine BASE_DIR on macOS." >&2
      return 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific setup
    if [[ -d "$HOME/Dropbox/matrix/shellscripts" ]]; then
      export BASE_DIR="$HOME/Dropbox/matrix/shellscripts"
    else
      echo "Error: Could not determine BASE_DIR on Linux." >&2
      return 1
    fi
  else
    echo "Error: Unsupported operating system." >&2
    return 1
  fi
}

# Ensure the credentials path is set
check_credentials_path() {
  if [[ -z "$CREDENTIALS_PATH" ]]; then
    echo "Error: CREDENTIALS_PATH is not set. Ensure it is defined in the .env file or set manually." >&2
    return 1
  fi
}

# Initialize setup
set_dropbox_path || exit 1
set_base_dir || exit 1
load_env_variables || exit 1
check_credentials_path || exit 1
