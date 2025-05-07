#!/bin/bash

SHARE="//192.168.0.51/datasets"
USER="maccou"
PASSWORD="Nautilus12@"
REMOTE_PATH="3D/stp"
LOCAL_PATH="./downloaded_files"

mkdir -p "$LOCAL_PATH"

# Explicitly define the list of directories
DIR_LIST=("Le_Belier" "Airbus" "Safran" "AH" "Stelia" "Renault" "Daher" "Renault_parts" "Mecachrome")

# Function to retrieve files from a directory
retrieve_files() {
    local dir=$1
    local local_dir="$LOCAL_PATH/$dir"  # Added this line to define local_dir
    echo "Retrieving files from $dir..."
    echo "Remote path: $REMOTE_PATH/$dir"
    echo "Local path: $local_dir"

    smbclient "$SHARE" -U "$USER%$PASSWORD" -c "cd \"$REMOTE_PATH/$dir\"; lcd \"$local_dir\"; prompt; mget *"
}

# Create local directories for each remote directory
for dir in "${DIR_LIST[@]}"; do
    mkdir -p "$LOCAL_PATH/$dir"
done

# Retrieve files from each directory
for dir in "${DIR_LIST[@]}"; do
    retrieve_files "$dir"
done

echo "File retrieval complete."
