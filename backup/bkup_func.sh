function bkbash() {
    # Default Dropbox location if not set
    if [ -z "$DROPBOX" ]; then
        export DROPBOX="/Users/suhail/Library/CloudStorage/Dropbox"
        echo "DROPBOX variable not set. Using default: $DROPBOX"
    fi

    # Default values
    local user="suhail"
    local ip=""
    
    # Parse the command-line options
    while getopts "u:i:" opt; do
        case $opt in
            u) user="$OPTARG" ;;   # Optional username
            i) ip="$OPTARG" ;;     # Mandatory IP address
            \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
        esac
    done

    # Check if IP is provided
    if [ -z "$ip" ]; then
        echo "IP address (-i) is required."
        return 1
    fi

    # Define the destination path for the backup
    local backup_dir="$DROPBOX/matrix/backups/bash"
    
    # Ensure the backup directory exists
    mkdir -p "$backup_dir"
    
    # Run the SCP command
    scp "${user}@${ip}:/home/${user}/.bashrc" "$backup_dir/"
    
    echo "Backup of .bashrc from ${user}@${ip} complete!"
}

function bkclitools() {
    # Default Dropbox location if not set
    if [ -z "$DROPBOX" ]; then
        export DROPBOX="/Users/suhail/Library/CloudStorage/Dropbox"
        echo "DROPBOX variable not set. Using default: $DROPBOX"
    fi

    # Default values
    local user="suhail"
    local ip=""
    
    # Parse the command-line options
    while getopts "u:i:" opt; do
        case $opt in
            u) user="$OPTARG" ;;   # Optional username
            i) ip="$OPTARG" ;;     # Mandatory IP address
            \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
        esac
    done

    # Check if IP is provided
    if [ -z "$ip" ]; then
        echo "IP address (-i) is required."
        return 1
    fi

    # Define the destination path for the backup
    local backup_dir="$DROPBOX/matrix/backups/bash/cliUtils"
    
    # Ensure the backup directory exists
    mkdir -p "$backup_dir"
    
    # Run the SCP command to copy the CONTENTS of the cliUtils directory, not the folder itself
    scp -r "${user}@${ip}:/home/${user}/tools/cliUtils/*" "$backup_dir/"
    
    echo "Backup of cliUtils from ${user}@${ip} complete!"
}
