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
    fi
}

# Set the global $DROPBOX environment variable only if it is not already set
set_datalib_path() {
    if [[ -z "$DATALIB" ]]; then
        platform=$(detect_platform)
        if [[ "$platform" == "macOS" ]]; then
            export DATALIB="$HOME/Library/CloudStorage/SynologyDrive-dataLib"
        elif [[ "$platform" == "Linux" ]]; then
            export DATALIB="$HOME/SynologyDrive"
        else
            echo "Unsupported platform. Exiting."
            exit 1
        fi
    fi
}


# Initialize the $DROPBOX variable
set_dropbox_path
set_datalib_path

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
create_env_function "helperScripts" "helperScripts" "helperScripts"
create_env_function "Incept" "Incept" "Incept"
create_env_function "pariVaha" "pariVaha" "pariVaha"
create_env_function "Lumiera" "Lumiera" "Lumiera"
create_env_function "Ledu" "Ledu" "Ledu"

create_publish_function() {
    local env_name="$1"
    local poetry_project="$2"
    eval "$(cat <<EOF
publish_${env_name}() {
    # Save current directory
    local current_dir=\$(pwd)

    # Set PROJECT_ROOT if not already set
    if [[ -z "\$PROJECT_ROOT" ]]; then
        export PROJECT_ROOT="\$DROPBOX/matrix/packages/${poetry_project}"
    fi

    # Change to the project root
    cd "\$PROJECT_ROOT" || return 1

    # Read the current version from pyproject.toml.
    # Assumes the version line is like: version = "0.1.32"
    local version_line=\$(grep '^version' pyproject.toml | head -1)
    local current_version=\$(echo "\$version_line" | sed -E 's/version = "([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')
    
    # Split into major, minor, patch and increment patch version
    IFS='.' read -r major minor patch <<< "\$current_version"
    local new_patch=\$((patch + 1))
    local new_version="\${major}.\${minor}.\${new_patch}"

    echo "Incrementing version: \$current_version -> \$new_version"

    # Update the version in pyproject.toml (creates a backup with .bak)
    sed -i.bak -E "s#(version = \")\$current_version(\".*)#\1\$new_version\2#" pyproject.toml

    # Build and publish using poetry
    poetry publish --build

    # Return to the original directory
    cd "\$current_dir" || return 1
}
EOF
)"
}

# Generate publish functions for each environment.
# For instance, if you have an environment called Incept:
create_publish_function "Incept" "Incept"
create_publish_function "notionManager" "notionManager"
create_publish_function "pythonKitchen" "pythonKitchen"
create_publish_function "oauthManager" "oauthManager"
create_publish_function "pariVaha" "pariVaha"
create_publish_function "Lumiera" "Lumiera"
create_publish_function "Ledu" "Ledu"

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
notionManager() {
    set_env_vars() {
        if [[ -z "$PROJECT_ROOT" ]]; then
            export PROJECT_ROOT="$DROPBOX/matrix/packages/notionManager"
        fi

        # Set PREFECT_API_URL if not already set
        if [[ -z "$PREFECT_API_URL" ]]; then
            export PREFECT_API_URL="http://10.81.29.44:4200/api"
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
