#!/bin/bash

set_env_vars() {
  if [[ -z "$VFX_LIB" ]]; then
    export VFX_LIB="$HOME/Library/CloudStorage/SynologyDrive-NAS/threeD/lib"
  fi
  if [[ -z "$MATRIX" ]]; then
    export MATRIX="$HOME/Library/CloudStorage/Dropbox/matrix"
  fi
  if [[ -z "$DROPBOX" ]]; then
    export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
  fi
  if [[ -z "$USD_LIB" ]]; then
    export USD_LIB="$HOME/Library/CloudStorage/SynologyDrive-NAS/threeD/lib/usd"
  fi

  if [[ -z "$ASSET_INGEST_DIR" ]]; then
    export ASSET_INGEST_DIR="$HOME/Library/CloudStorage/SynologyDrive-NAS/threeD/lib/ingest"
  fi

  if [[ -z "$HOUDINI_USER_PREF_DIR" ]]; then
    export HOUDINI_USER_PREF_DIR="$HOME/Library/CloudStorage/Dropbox/appSettings/houdini/mac/20.5"
  fi
}
set_env_vars

