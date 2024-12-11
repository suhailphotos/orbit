#!/bin/bash

# Detect the base directory dynamically
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS-specific setup
  if [[ -d "$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts" ]]; then
    export BASE_DIR="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts"
  elif [[ -d "$HOME/Documents/tools/cliUtils" ]]; then
    export BASE_DIR="$HOME/Documents/tools/cliUtils"
  else
    echo "Error: Could not determine BASE_DIR on macOS."
    exit 1
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux-specific setup
  if [[ -d "$HOME/Dropbox/matrix/shellscripts" ]]; then
    export BASE_DIR="$HOME/Dropbox/matrix/shellscripts"
  else
    echo "Error: Could not determine BASE_DIR on Linux."
    exit 1
  fi
else
  echo "Error: Unsupported operating system."
  exit 1
fi

# Notify the user
echo "BASE_DIR set to $BASE_DIR"
