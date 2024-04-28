#!/bin/bash

set_env_vars() {
  if [[ -z "$VFX_LIB" ]]; then
    export VFX_LIB="$HOME/Library/CloudStorage/Dropbox/threeD/lib"
  fi

  if [[ -z "$USD_LIB" ]]; then
    export USD_LIB="$HOME/Library/CloudStorage/Dropbox/threeD/lib/usd"
  fi

  if [[ -z "$ASSET_INGEST_DIR" ]]; then
    export ASSET_INGEST_DIR="/Volumes/HomeFolder/threeD/lib/ingest"
  fi

  if [[ -z "$HOUDINI_USER_PREF_DIR" ]]; then
    export HOUDINI_USER_PREF_DIR="$HOME/Documents/houdini/houUserPref/20.0"
  fi
}
set_env_vars

