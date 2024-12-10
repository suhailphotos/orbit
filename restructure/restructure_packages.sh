#!/bin/bash

# List of packages to restructure
packages=("pythonKitchen" "ocioTools" "nukeUtils" "hdrUtils")
base_dir="/Users/suhail/Library/CloudStorage/Dropbox/matrix/packages"
temp_dir="/Users/suhail/Desktop"

# Function to restructure a package
restructure_package() {
    local package_name=$1

    echo "Processing $package_name..."

    # Commit current changes
    cd "$base_dir/$package_name" || { echo "Package not found: $package_name"; return; }
    lazygit "Prior to restructure commit"

    # Move package to temporary location
    mv "$base_dir/$package_name" "$temp_dir/${package_name}_temp"

    # Create a new structure using Poetry
    cd "$base_dir"
    poetry new --src "$package_name"

    # Copy hidden and other files, excluding specific items
    rsync -a "$temp_dir/${package_name}_temp/.*" "$base_dir/$package_name/" || echo "No hidden files to copy."
    rsync -av --progress "$temp_dir/${package_name}_temp/" "$base_dir/$package_name/" --exclude=src --exclude=pyproject.toml --exclude=$package_name

    # Move package-specific files into the `src` folder
    rsync -av --progress "$temp_dir/${package_name}_temp/$package_name/" "$base_dir/$package_name/src/$package_name/"

    # Update pyproject.toml (example provided; adjust if needed)
    cat <<EOF > "$base_dir/$package_name/pyproject.toml"
[tool.poetry]
name = "$package_name"
version = "0.1.0"
description = "Package description for $package_name"
authors = ["Suhail <suhailece@gmail.com>"]
license = "MIT"
readme = "README.md"
packages = [{include = "$package_name", from = "src"}]

[tool.poetry.dependencies]
python = "3.10.10"
# Add any package-specific dependencies here

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
EOF

    # Remove old Poetry lock file and set up the new environment
    rm "$base_dir/$package_name/poetry.lock"
    cd "$base_dir/$package_name"
    poetry env use "$(pyenv prefix 3.10.10)/bin/python"
    poetry lock
    source "$(poetry env info --path)/bin/activate"
    poetry install
    poetry check

    # Commit the updated structure
    lazygit "Updated folder structure for $package_name"
    poetry deactivate

    echo "Completed restructuring for $package_name."
}

# Process all packages
for package in "${packages[@]}"; do
    restructure_package "$package"
done

# Special handling for houdiniUtils (if needed, add custom steps here)
echo "Special handling for houdiniUtils required. Manual steps may apply."
