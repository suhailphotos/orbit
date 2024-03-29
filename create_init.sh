#!/bin/bash

# Define the root directory
root_dir="packages"

# Define the list of subdirectories and their subfolders
subdirectories=(
    "blenderUtils"
    "hdrUtils/gainMap"
    "houdiniUtils/fSpy"
    "houdiniUtils/hda"
    "houdiniUtils/houdiniNet"
    "houdiniUtils/importhou"
    "houdiniUtils/projTools"
    "houdiniUtils/refCode"
    "nukeUtils"
    "pythonKitchen/lazyEval"
    "usdUtils/glb2usd"
    "webUtils/gui"
)

# Create the root directory if it doesn't exist
mkdir -p "$root_dir"

# Loop through each subdirectory and its subfolders
for directory in "${subdirectories[@]}"; do
    # Create the directory and its subfolders if they don't exist
    mkdir -p "$root_dir/$directory"
    # Create the __init__.py file if it doesn't exist
    if [ ! -f "$root_dir/$directory/__init__.py" ]; then
        touch "$root_dir/$directory/__init__.py"
    else
        echo "Skipping __init__.py creation for $directory as it already exists."
    fi
done

# Create the __init__.py file for the root directory if it doesn't exist
if [ ! -f "$root_dir/__init__.py" ]; then
    touch "$root_dir/__init__.py"
else
    echo "Skipping __init__.py creation for root directory as it already exists."
fi

echo "Directory structure created successfully."

