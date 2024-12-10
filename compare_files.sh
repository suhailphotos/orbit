#!/bin/zsh

DIR1="$HOME/Library/CloudStorage/Dropbox/matrix/shellscripts"
DIR2="$HOME/Documents/tools/cliUtils"

# Create temporary files to store hashes
DIR1_HASHES=$(mktemp)
DIR2_HASHES=$(mktemp)

# Function to calculate file hashes and store them in a temporary file
calculate_hashes() {
    local dir=$1
    local output_file=$2
    for file in "$dir"/*; do
        if [[ -f "$file" ]]; then
            local name=$(basename "$file")
            local hash=$(shasum -a 256 "$file" | awk '{print $1}')
            echo "$name $hash" >> "$output_file"
        fi
    done
}

# Calculate hashes for both directories
calculate_hashes "$DIR1" "$DIR1_HASHES"
calculate_hashes "$DIR2" "$DIR2_HASHES"

# Compare files
echo "Comparing files between $DIR1 and $DIR2..."
while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    hash=$(echo "$line" | awk '{print $2}')
    dir2_hash=$(grep "^$name " "$DIR2_HASHES" | awk '{print $2}')

    if [[ -n "$dir2_hash" ]]; then
        if [[ "$hash" != "$dir2_hash" ]]; then
            echo "Different content: $name"
        fi
    else
        echo "Unique to $DIR1: $name"
    fi
done < "$DIR1_HASHES"

while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    dir1_hash=$(grep "^$name " "$DIR1_HASHES" | awk '{print $2}')

    if [[ -z "$dir1_hash" ]]; then
        echo "Unique to $DIR2: $name"
    fi
done < "$DIR2_HASHES"

# Clean up temporary files
rm -f "$DIR1_HASHES" "$DIR2_HASHES"
