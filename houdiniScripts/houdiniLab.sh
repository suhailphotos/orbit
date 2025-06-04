#!/bin/bash

houdiniLab() {
    local user_version="$1"          # Version override, if provided (e.g., 20.5.584)
    local command="$2"               # Optional subcommand (-e or -hou)
    local houdini_version

    # Function to get latest Houdini version installed
    get_latest_houdini_version() {
        ls -d /Applications/Houdini/Houdini* 2>/dev/null | \
            sed 's|/Applications/Houdini/Houdini||' | sort -Vr | head -n 1
    }

    # If user provided a version as first argument, use it; otherwise use latest
    if [[ -n "$user_version" && ! "$user_version" =~ ^- ]]; then
        houdini_version="$user_version"
        # Check if directory exists
        if [[ ! -d "/Applications/Houdini/Houdini$houdini_version" ]]; then
            echo "Warning: Houdini version $houdini_version not found in /Applications/Houdini/" >&2
            return 1
        fi
        shift   # Remove version arg, so next arg is the command
        command="$1"
    else
        houdini_version=$(get_latest_houdini_version)
        if [[ -z "$houdini_version" ]]; then
            echo "Warning: No Houdini install found in /Applications/Houdini/" >&2
            return 1
        fi
    fi

    set_houdini_user_pref() {
        export HOUDINI_USER_PREF_DIR="$HOME/Library/Preferences/houdini/${houdini_version%.*}"
    }

    change_dir_activate() {
        if [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniLab" && "$VIRTUAL_ENV" != "" ]]; then
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniLab" || return 1
        elif [[ "$(pwd)" != "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniLab" && "$VIRTUAL_ENV" == "" ]]; then
            cd "$HOME/Library/CloudStorage/Dropbox/matrix/packages/houdiniLab" || return 1
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

    # Run actions
    if [ -n "$command" ]; then
        if [ "$command" = "-e" ]; then
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
        elif [ "$command" = "-hou" ]; then
            if [[ -z "$PYTHONPATH" && -z "$DYLD_INSERT_LIBRARIES" ]]; then
                change_dir_activate
                set_env_vars
                python3 ./houdiniutils/importhou/importhou.py || return 1
            else
                change_dir_activate
                python3 ./houdiniutils/importhou/importhou.py || return 1
            fi
        fi
    else
        change_dir_activate
    fi
}
