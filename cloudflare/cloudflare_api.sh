#!/bin/bash

# Ensure BASE_DIR is set
if [[ -z "$BASE_DIR" ]]; then
  echo "Error: BASE_DIR is not set. Please source setup_env.sh first."
  exit 1
fi

# Path to the .env file
ENV_FILE="$BASE_DIR/envars/.env"

# Check if .env file exists
if [ -f "$ENV_FILE" ]; then
  # Load the .env file
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Error: .env file not found at $ENV_FILE. Please create it and add the necessary credentials."
  exit 1
fi

# Use the credentials
if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_TECH" ]; then
  echo "Error: CLOUDFLARE_API_TOKEN_SUHAIL_TECH is not set in the .env file."
  exit 1
fi

if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_LIFE" ]; then
  echo "Error: CLOUDFLARE_API_TOKEN_SUHAIL_LIFE is not set in the .env file."
  exit 1
fi

if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS" ]; then
  echo "Error: CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS is not set in the .env file."
  exit 1
fi

if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_ART" ]; then
  echo "Error: CLOUDFLARE_API_TOKEN_SUHAIL_ART is not set in the .env file."
  exit 1
fi

# Example usage
echo "Cloudflare API tokens successfully loaded."
echo "Using token for suhail.tech: $CLOUDFLARE_API_TOKEN_SUHAIL_TECH"
