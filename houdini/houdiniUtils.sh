#!/bin/bash

houdiniUtils() {
    local houdini_version="20.5.278"  # Default Houdini version
    local optional_command="$1"

    set_houdini_user_pref() {
      if [[ -z "$HOUDINI_USER_PREF_DIR" ]]; then
          export HOUDINI_USER_PREF_DIR="$HOME/Library/CloudStorage/Dropbox/appSettings/houdini/mac/20.5"
      fi
    }
    
    
    change_dir_activate() {
        # Check if already in the desired directory and environment is activated
        if [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils" && "$VIRTUAL_ENV" != "" ]]; then
            # If not in the directory, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils" || return 1
        elif [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils" && "$VIRTUAL_ENV" == ""  ]]; then
            # If not in the directory and environment is already active, change directory
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniUtils" || return 1
            source "$(poetry env info --path)/bin/activate" || return 1
        fi
    }

    set_env_vars() {
        export PYTHONPATH="/Applications/Houdini/Houdini${houdini_version}/Frameworks/Houdini.framework/Versions/Current/Resources/houdini/python3.11libs"
        export DYLD_INSERT_LIBRARIES="/Applications/Houdini/Houdini${houdini_version}/Frameworks/Houdini.framework/Versions/Current/Houdini"
        cd "/Applications/Houdini/Houdini${houdini_version}/Frameworks/Houdini.framework/Versions/Current/Resources" || return 1
        source ./houdini_setup || return 1
        cd - || return 1
    }

    if [ -n "$optional_command" ]; then
        if [ "$optional_command" = "-e" ]; then
            if [[ -z "$PYTHONPATH" && -z "$DYLD_INSERT_LIBRARIES" ]]; then
                change_dir_activate
                set_houdini_user_pref
                set_env_vars
            else
                change_dir_activate
                set_houdini_user_pref
                echo "Environment variables are already active"
                return 1
            fi
        elif [ "$optional_command" = "-hou" ]; then
            if [[ -z "$PYTHONPATH" && -z "$DYLD_INSERT_LIBRARIES" ]]; then
                change_dir_activate
                #set_houdini_user_pref     Houdini user pref are set in all environments using setenvars.sh (so not necessary here)
                set_env_vars
                python3 ./houdiniutils/importhou/importhou.py || return 1
            else
                change_dir_activate
                #set_houdini_user_pref
                python3 ./houdiniutils/importhou/importhou.py || return 1
            fi
        fi
    else
        change_dir_activate
        #set_houdini_user_pref
    fi
}

