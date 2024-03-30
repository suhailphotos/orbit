#!/bin/bash

# Define USD_INSTALL_ROOT outside of any function
USD_INSTALL_ROOT="/Users/suhail/openUSD/built"

usdUtils() {
    set_env_vars() {
        # Export USD_INSTALL_ROOT if not already set
        if [[ -z "$USD_INSTALL_ROOT" ]]; then
            export USD_INSTALL_ROOT="$USD_INSTALL_ROOT"
        fi

        # Export PYTHONPATH if not already set
        if [[ -z "$PYTHONPATH" ]]; then
            export PYTHONPATH="$USD_INSTALL_ROOT/lib/python"
        fi

        # Prepend USD_INSTALL_ROOT/bin to PATH if not already included
        if [[ ":$PATH:" != *":$USD_INSTALL_ROOT/bin:"* ]]; then
            export PATH="$USD_INSTALL_ROOT/bin:$PATH"
        fi
    }

    change_dir_activate() {
        # Check if already in the desired directory and environment is activated
        if [[ "$(pwd)" != "$HOME/Documents/matrix/packages/usdUtils/" && "$VIRTUAL_ENV" != "" ]]; then
            # If not in the directory, change directory
            cd "$HOME/Documents/matrix/packages/usdUtils/" || return 1
            set_env_vars
        elif [[ "$(pwd)" != "$HOME/Documents/matrix/packages/usdUtils/" && "$VIRTUAL_ENV" == ""  ]]; then
            # If not in the directory and environment is already active, change directory
            cd "$HOME/Documents/matrix/packages/usdUtils/" || return 1
            source "$(poetry env info --path)/bin/activate" || return 1
            set_env_vars
        fi
    }
    
    # Call the change_dir_activate function
    change_dir_activate
}
