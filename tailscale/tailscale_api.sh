#!/bin/bash

# Ensure BASE_DIR is set
if [[ -z "$BASE_DIR" ]]; then
  echo "Error: BASE_DIR is not set. Please source setup_env.sh first." >&2
  return 1
fi

# Ensure TS_AUTHKEY is set
if [[ -z "$TS_AUTHKEY" ]]; then
  echo "Error: TS_AUTHKEY is not set. Ensure it is defined in the .env file." >&2
  return 1
fi

# Example usage
echo "TailScale API key successfully loaded."
