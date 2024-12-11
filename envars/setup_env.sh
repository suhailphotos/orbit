#!/bin/bash

# Function to load environment variables from a .env file
load_env_variables() {
  if [[ -f "$BASE_DIR/envars/.env" ]]; then
    export $(grep -v '^#' "$BASE_DIR/envars/.env" | sed "s|\$DROPBOX|$DROPBOX|g" | xargs)
  else
    echo "Error: .env file not found in $BASE_DIR/envars." >&2
    exit 1
  fi
}

# Detect the base directory dynamically
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS-specific setup
  if [[ -d "$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts" ]]; then
    export BASE_DIR="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts"
    export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
  elif [[ -d "$HOME/Documents/tools/cliUtils" ]]; then
    export BASE_DIR="$HOME/Documents/tools/cliUtils"
    export DROPBOX="$HOME/Library/CloudStorage/Dropbox" # Adjust as needed for Mac-specific logic
  else
    echo "Error: Could not determine BASE_DIR on macOS." >&2
    exit 1
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux-specific setup
  if [[ -d "$HOME/Dropbox/matrix/shellscripts" ]]; then
    export BASE_DIR="$HOME/Dropbox/matrix/shellscripts"
    export DROPBOX="$HOME/Dropbox"
  else
    echo "Error: Could not determine BASE_DIR on Linux." >&2
    exit 1
  fi
else
  echo "Error: Unsupported operating system." >&2
  exit 1
fi

# Load environment variables from .env file
load_env_variables

# Ensure CREDENTIALS_PATH is set
if [[ -z "$CREDENTIALS_PATH" ]]; then
  echo "Error: CREDENTIALS_PATH is not set. Ensure it is defined in the .env file or set manually." >&2
  exit 1
fi
