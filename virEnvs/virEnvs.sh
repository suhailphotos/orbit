#!/bin/bash

# Helper function to detect the platform
detect_platform() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "macOS"
    elif [[ "$(uname)" == "Linux" ]]; then
        echo "Linux"
    else
        echo "Unsupported"
    fi
}

# Set the global $DROPBOX environment variable only if it is not already set
set_dropbox_path() {
    if [[ -z "$DROPBOX" ]]; then
        platform=$(detect_platform)
        if [[ "$platform" == "macOS" ]]; then
            export DROPBOX="$HOME/Library/CloudStorage/Dropbox"
        elif [[ "$platform" == "Linux" ]]; then
            export DROPBOX="$HOME/Dropbox"
        else
            echo "Unsupported platform. Exiting."
            exit 1
        fi
    else
        echo "DROPBOX environment variable is already set to: $DROPBOX"
    fi
}

# Initialize the $DROPBOX variable
set_dropbox_path

# Utility function template
create_env_function() {
    local env_name="$1"
    local poetry_project="$2"
    local conda_project="$3"

    eval "$env_name() {
        set_env_vars() {
            if [[ -z \"\$PROJECT_ROOT\" ]]; then
                export PROJECT_ROOT=\"\$DROPBOX/matrix/packages/$poetry_project\"
            fi
            echo \"PROJECT_ROOT set to \$PROJECT_ROOT\"
        }

        change_dir_activate() {
            platform=\$(detect_platform)
            if [[ \"\$platform\" == \"macOS\" ]]; then
                if [[ \"\$(pwd)\" != \"\$PROJECT_ROOT\" && -z \"\$VIRTUAL_ENV\" ]]; then
                    cd \"\$PROJECT_ROOT\" || return 1
                    source \"\$(poetry env info --path)/bin/activate\" || return 1
                elif [[ \"\$(pwd)\" != \"\$PROJECT_ROOT\" ]]; then
                    cd \"\$PROJECT_ROOT\" || return 1
                fi
            elif [[ \"\$platform\" == \"Linux\" ]]; then
                if [[ \"\$(pwd)\" != \"\$PROJECT_ROOT\" && -z \"\$CONDA_PREFIX\" ]]; then
                    cd \"\$PROJECT_ROOT\" || return 1
                    conda activate $conda_project || return 1
                elif [[ \"\$(pwd)\" != \"\$PROJECT_ROOT\" ]]; then
                    cd \"\$PROJECT_ROOT\" || return 1
                fi
            fi
        }

        # Call the functions to set environment variables and activate the environment
        set_env_vars
        change_dir_activate
    }"
}

# Generate functions for each environment
create_env_function "usdUtils" "usdUtils" "usdUtils"
create_env_function "oauthManager" "oauthManager" "oauthManager"
create_env_function "pythonKitchen" "pythonKitchen" "pythonKitchen"
create_env_function "ocioTools" "ocioTools" "ocioTools"

# Function for HoudiniPublish (special case)
houdiniPublish() {
    set_env_vars() {
        if [[ -z "$PROJECT_ROOT" ]]; then
            export PROJECT_ROOT="$HOME/.virtualenvs/houdiniPublish"
        fi
    }

    change_dir_activate() {
        cd "$PROJECT_ROOT" || return 1
        source "$PROJECT_ROOT/bin/activate" || return 1
    }

    set_env_vars
    change_dir_activate
}

# Function for NotionUtils
notionUtils() {
    set_env_vars() {
        if [[ -z "$PROJECT_ROOT" ]]; then
            export PROJECT_ROOT="$DROPBOX/matrix/packages/notionUtils"
        fi
    }

    change_dir_activate() {
        platform=$(detect_platform)
        if [[ "$platform" == "macOS" ]]; then
            if [[ "$(pwd)" != "$PROJECT_ROOT" && -z "$VIRTUAL_ENV" ]]; then
                cd "$PROJECT_ROOT" || return 1
                source "$(poetry env info --path)/bin/activate" || return 1
            elif [[ "$(pwd)" != "$PROJECT_ROOT" ]]; then
                cd "$PROJECT_ROOT" || return 1
            fi
        elif [[ "$platform" == "Linux" ]]; then
            if [[ "$(pwd)" != "$PROJECT_ROOT" && -z "$CONDA_PREFIX" ]]; then
                cd "$PROJECT_ROOT" || return 1
                conda activate notionUtils || return 1
            elif [[ "$(pwd)" != "$PROJECT_ROOT" ]]; then
                cd "$PROJECT_ROOT" || return 1
            fi
        fi
    }

    set_env_vars
    change_dir_activate
}
