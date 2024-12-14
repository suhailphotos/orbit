#!/bin/bash

# Ensure BASE_DIR is set
if [[ -z "$BASE_DIR" ]]; then
  echo "Warning: BASE_DIR is not set. Please source setup_env.sh first." >&2
  return 1
fi

# Path to the .env file
ENV_FILE="$BASE_DIR/envars/.env"

# Check if .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Warning: .env file not found at $ENV_FILE. Please create it and add the necessary credentials." >&2
  return 1
fi

# Load the .env file
export $(grep -v '^#' "$ENV_FILE" | xargs) || {
  echo "Warning: Failed to load environment variables from $ENV_FILE." >&2
  return 1
}

# Validate credentials
[[ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_TECH" ]] && {
  echo "Warning: CLOUDFLARE_API_TOKEN_SUHAIL_TECH is not set in the .env file." >&2
}

[[ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_LIFE" ]] && {
  echo "Warning: CLOUDFLARE_API_TOKEN_SUHAIL_LIFE is not set in the .env file." >&2
}

[[ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS" ]] && {
  echo "Warning: CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS is not set in the .env file." >&2
}

[[ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_ART" ]] && {
  echo "Warning: CLOUDFLARE_API_TOKEN_SUHAIL_ART is not set in the .env file." >&2
}

# Silent success: No output unless there's an issue
