#!/usr/bin/env bash
# $1 is the Houdini temp filename

file="$1"

# 1) launch VS Code on it
open -a "Visual Studio Code" "$file"

# 2) hold the script alive for a moment
#    so that Houdini doesn’t delete the file before VS Code grabs it
sleep 1
