#!/bin/zsh

# Base directory
base_dir="/Users/suhail/Library/CloudStorage/Dropbox/matrix/shellscripts"

# Create subfolders and move files
declare -A folders=(
    [aliases]="aliases.sh"
    [backup]="bkup_func.sh"
    [cloudflare]="cloudflare_api.sh"
    [compare_utils]="compare_files.sh"
    [create_init]="create_init.sh"
    [envars]="envars.json setenvars.py setenvars.sh"
    [git_utils]="gitUtils.sh"
    [houdini]="houdiniEnvSet.sh houdiniLab.sh houdiniUtils.sh"
    [nuke]="nukeUtils.sh"
    [restructure]="restructure_packages.sh"
    [tailscale]="tailscale_api.sh"
    [virEnvs]="virEnvs.sh virEnvs_v0.sh"
)

for folder in ${(k)folders}; do
    # Create subfolder
    mkdir -p "$base_dir/$folder"
    
    # Move files to subfolder
    for file in ${(s: :)folders[$folder]}; do
        if [[ -f "$base_dir/$file" ]]; then
            mv "$base_dir/$file" "$base_dir/$folder/"
        fi
    done
done

echo "Reorganization complete!"
