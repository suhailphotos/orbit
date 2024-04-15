#!/bin/bash

# Main function
update_houdini_env() {
    local environment="$1"
    local original_dir="$(pwd)"  # Store the original directory

    # Function to retrieve the path of Python packages for the specified environment
    get_python_packages_path() {
        cd "$HOME/Documents/matrix/packages/$environment" || {
            echo "Error: Failed to change directory to $HOME/Documents/matrix/packages/$environment"
            return 1
        }

        # Activate environment if not already activated
        if [[ -z "$VIRTUAL_ENV" ]]; then
            source "$(poetry env info --path)/bin/activate" || {
                echo "Error: Failed to activate environment for $environment"
                return 1
            }
        fi

        poetry_env_path=$(poetry env info --path)
        if [ -z "$poetry_env_path" ]; then
            echo "Error: Poetry environment path not found for $environment"
            return 1
        fi

        python_packages_path="$poetry_env_path/lib/python3.10/site-packages"

        echo "$python_packages_path"
    }

    # Function to check if a path exists in the PYTHONPATH variable in houdini.env
    path_exists_in_houdini_env() {
        local path_to_check="$1"
        if grep -q "PYTHONPATH=\".*$path_to_check\"" "$HOUDINI_USER_PREF_DIR/houdini.env"; then
            return 0  # Path exists in houdini.env
        else
            return 1  # Path does not exist in houdini.env
        fi
    }

    # Function to append a path to the PYTHONPATH variable in houdini.env
    append_path_to_houdini_env() {
        local path_to_append="$1"
        echo "Appending $path_to_append to PYTHONPATH in houdini.env"
        echo "PYTHONPATH=\"\${PYTHONPATH}:$path_to_append\"" >> "$HOUDINI_USER_PREF_DIR/houdini.env"
    }

    # Call the get_python_packages_path function
    python_packages_path=$(get_python_packages_path)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Python packages path for $environment"
        return 1
    fi

    # Check if the path already exists in houdini.env
    if path_exists_in_houdini_env "$python_packages_path"; then
        echo "The path $python_packages_path already exists in houdini.env"
    else
        # Append the path to houdini.env
        append_path_to_houdini_env "$python_packages_path"
        echo "Updated houdini.env with the path $python_packages_path"
    fi

    # Change back to the original directory
    cd "$original_dir" || {
        echo "Error: Failed to change back to the original directory"
        return 1
    }
}

# Call the main function with the environment name as argument (change "usdUtils" to your desired environment)
# update_houdini_env "usdUtils"
