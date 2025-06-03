set dotenv-load := false
set export := true

project-name := "new-project"
gitignore-path := "$HOME/.config/git/gitignore"

[no-cd]
@_default:
    just --list

# Create a new library with src layout. Used for packaging.
[no-cd]
@new-library name=project-name:
    echo "Installing UV"
    just _install-uv

    mkdir {{ name }}
    just _bootstrap library {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow
    cp {{ gitignore-path }} {{ name }}/.gitignore

# Create a new application. Useful for web apps, scripts, or CLIs.
[no-cd]
@new-app name=project-name:
    echo "Installing UV"
    just _install-uv

    mkdir {{ name }}
    just _bootstrap app {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow
    cp {{ gitignore-path }} {{ name }}/.gitignore

# Bootstrap a new project.
[no-cd]
_bootstrap type project:
    #!/bin/bash
    set -euxo pipefail
    if command -v uv &> /dev/null; then 
        just _uv-init {{ type }} {{ project }} 
    else 
        just _uv-init {{ type }} {{ project }} 
    fi

# Convert a classical git repo to a bare repo.
[no-cd]
repo-to-bare folder:
    #!/bin/bash

    cd {{folder}}
    mv .git ../{{folder}}.git
    cd ..
    rm -rf {{folder}}
    cd {{folder}}.git
    git config --bool core.bare true

# Creates a project with or without src layout based on uv init command.
[no-cd]
_uv-init type project:
    #!/bin/bash

    TYPE="${type}"
    PROJECT_NAME="$project"

    if [ "$TYPE" == "library" ]; then
        uv init --lib "$PROJECT_NAME"
    else
        uv init --app "$PROJECT_NAME"
    fi

[no-cd]
@_install-uv:
    curl -LsSf https://astral.sh/uv/install.sh | sh

# Retrieve the latest file created in the mirror remote directory.
[no-cd]
@retrieve-latest-file user host:
    #!/bin/bash

    REMOTE_USER="${user}"
    REMOTE_HOST="${host}"
    REMOTE_DIR=$(pwd)

    MOST_RECENT_FILE=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -t ${REMOTE_DIR} | head -n 1")

    if [ -z "$MOST_RECENT_FILE" ]; then
    echo "No files found in the remote directory."
    exit 1
    fi

    scp -v ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${MOST_RECENT_FILE} .

# Sync files from a text file with a remote host (faster version using the current directory)
[no-cd]
@sync-files user host direction="down" file_list="files.txt":
    #!/usr/bin/env bash
    
    REMOTE_USER="${user}"
    REMOTE_HOST="${host}"
    REMOTE_DIR=$(pwd)
    LOCAL_DIR=$(pwd)
    FILE_LIST="${file_list}"
    TEMP_FILE=$(mktemp)
    
    # Verify the file list exists
    if [ ! -f "${FILE_LIST}" ]; then
        echo "Error: ${FILE_LIST} not found in the current directory."
        exit 1
    fi
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        # Trim leading and trailing whitespace but preserve the line
        trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        echo "$trimmed_line" >> "${TEMP_FILE}"
    done < "${FILE_LIST}"
    
    if [ ! -s "${TEMP_FILE}" ]; then
        echo "Error: No valid file entries found in ${FILE_LIST} after filtering."
        rm "${TEMP_FILE}"
        exit 1
    fi
    
    # Count the number of files to transfer
    FILE_COUNT=$(wc -l < "${TEMP_FILE}")
    echo "Preparing to sync ${FILE_COUNT} files..."
    
    if [ "${direction}" == "up" ]; then
        echo "Uploading files to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
        # Create remote directory if it doesn't exist
        ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p \"${REMOTE_DIR}\""
        # Use rsync with --files-from to transfer all files at once
        rsync -avz --progress --files-from="${TEMP_FILE}" "${LOCAL_DIR}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
    elif [ "${direction}" == "down" ]; then
        echo "Downloading files from ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
        # Use rsync with --files-from to transfer all files at once
        rsync -avz --progress --files-from="${TEMP_FILE}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" "${LOCAL_DIR}/"
    else
        echo "Invalid direction. Use 'up' to sync to remote or 'down' to sync from remote."
        rm "${TEMP_FILE}"
        exit 1
    fi
    
    # Clean up
    rm "${TEMP_FILE}"
    
    echo "File sync completed successfully."

# Sync the current directory with the remote directory or vice versa.
[no-cd]
@sync user host direction="down":
    #!/bin/bash

    REMOTE_USER="${user}"
    REMOTE_HOST="${host}"
    REMOTE_DIR=$(pwd)

    if [ "${direction}" == "up" ]; then
        rsync -avz . ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}
    elif [ "${direction}" == "down" ]; then
        rsync -avz ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/ .
    else
        echo "Invalid direction. Use 'up' to sync to remote or 'down' to sync from remote."
        exit 1
    fi

# Open the latest file in the current repository
[no-cd] 
@open-latest:
    #!/bin/bash
    LATEST_FILE=$(ls -t | head -n 1)
    if [ -z "$LATEST_FILE" ]; then
        echo "No files found in the current directory."
        exit 1
    fi
    
    if grep -q microsoft /proc/version; then
        # WSL environment
        wslview "$LATEST_FILE"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS environment
        open "$LATEST_FILE"
    else
        # Linux environment
        xdg-open "$LATEST_FILE"
    fi

[no-cd]
@restore-and-unstage branch filepath:
    git checkout {{ branch }} -- {{ filepath }}
    git restore --staged {{ filepath }}
