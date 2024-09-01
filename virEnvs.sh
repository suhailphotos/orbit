#!/bin/bash

usdUtils() {
    set_env_vars() {
        if [[ -z "$USD_INSTALL_ROOT" ]]; then
            export USD_INSTALL_ROOT="$HOME/openUSD/built"
        fi
  
        # Export PYTHONPATH if not already set
        if [[ -z "$PYTHONPATH" ]]; then
            export PYTHONPATH="$USD_INSTALL_ROOT/lib/python"
        fi

        # Prepend USD_INSTALL_ROOT/bin to PATH if not already included
        if [[ ":$PATH:" != *":$USD_INSTALL_ROOT/bin:"* ]]; then
            export PATH="$USD_INSTALL_ROOT/bin:$PATH"
        fi

        if [[ -z "$PROJECT_ROOT" ]]; then
            export PROJECT_ROOT="$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils"
        fi

    }

    change_dir_activate() {
        # Check if already in the desired directory and environment is activated
        if [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils/" && "$VIRTUAL_ENV" != "" ]]; then
            # If not in the directory, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils/" || return 1
        elif [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils/" && "$VIRTUAL_ENV" == ""  ]]; then
            # If not in the directory and environment is already active, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils/" || return 1
            source "$(poetry env info --path)/bin/activate" || return 1
        fi
    }
    
    # Call the change_dir_activate function
    set_env_vars
    change_dir_activate
}

pythonKitchen() {
  # Place holder setting any environment variables if needed 

    set_env_vars() {
        if [[ -z "$PROJECT_ROOT" ]]; then
            export PROJECT_ROOT="$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen"
        fi
  
        #if [[ -z "$VFX_LIB" ]]; then
        #    export VFX_LIB="$HOME/Library/CloudStorage/Dropbox/threeD/lib"
        #fi

        #if [[ ":$PATH:" != *":$USD_INSTALL_ROOT/bin:"* ]]; then
        #    export PATH="$USD_INSTALL_ROOT/bin:$PATH"
        #fi
   }

    change_dir_activate() {
        # Check if already in the desired directory and environment is activated
        if [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen/" && "$VIRTUAL_ENV" != "" ]]; then
            # If not in the directory, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen/" || return 1
        elif [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen/" && "$VIRTUAL_ENV" == ""  ]]; then
            # If not in the directory and environment is already active, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen/" || return 1
            source "$(poetry env info --path)/bin/activate" || return 1
        fi
    }
    
    # Call the change_dir_activate function
    set_env_vars
    change_dir_activate
    poetry run python "$HOME/Library/CloudStorage/Dropbox/matrix/packages/pythonKitchen/setupEnv.py"
}
ocioTools() {
    set_env_vars() {
       # if [[ -z "$USD_INSTALL_ROOT" ]]; then
       #     export USD_INSTALL_ROOT="$HOME/openUSD/built"
       # fi
  
       # # Export PYTHONPATH if not already set
       # if [[ -z "$PYTHONPATH" ]]; then
       #     export PYTHONPATH="$USD_INSTALL_ROOT/lib/python"
       # fi

       # # Prepend USD_INSTALL_ROOT/bin to PATH if not already included
       # if [[ ":$PATH:" != *":$USD_INSTALL_ROOT/bin:"* ]]; then
       #     export PATH="$USD_INSTALL_ROOT/bin:$PATH"
       # fi

       # if [[ -z "$PROJECT_ROOT" ]]; then
       #     export PROJECT_ROOT="$HOME/Library/CloudStorage/Dropbox/matrix/packages/usdUtils"
       # fi

    }

    change_dir_activate() {
        # Check if already in the desired directory and environment is activated
        if [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/ocioTools/" && "$VIRTUAL_ENV" != "" ]]; then
            # If not in the directory, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/ocioTools/" || return 1
        elif [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/ocioTools/" && "$VIRTUAL_ENV" == ""  ]]; then
            # If not in the directory and environment is already active, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/ocioTools/" || return 1
            source "$(poetry env info --path)/bin/activate" || return 1
        fi
    }
    
    # Call the change_dir_activate function
    set_env_vars
    change_dir_activate
}
houdiniPublish() {
    # Root directory of the virtual environment
    local vir_env_dir="$HOME/.virtualenvs/houdiniPublish"

    # Default action: change to the root of the virtual environment and activate
    if [[ "$1" == "packages" ]]; then
        # Optional command to jump to site-packages folder
        cd "$vir_env_dir/lib/python3.11/site-packages" || return 1
    else
        # Default action: change to the root of the virtual environment
        cd "$vir_env_dir" || return 1
        source "$vir_env_dir/bin/activate" || return 1
    fi
}
