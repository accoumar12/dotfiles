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
        rm "$PROJECT_NAME"/hello.py
    fi

[no-cd]
@_install-uv:
    python -m pip install \
                --disable-pip-version-check \
                --no-compile \
                --upgrade \
            pip uv

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

[no-cd]
@export-cads-to-csv :
    #!/usr/bin/env -S uv run --script

    import json
    import csv
    import os
    from pathlib import Path

    def main():
        json_file_path = Path('./cads.json')
        csv_file_path = Path('./cads.csv')
        
        # Read the JSON file
        try:
            with open(json_file_path, 'r') as json_file:
                cad_data = json.load(json_file)
        except FileNotFoundError:
            print(f"Error: Could not find {json_file_path}")
            return
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON format in {json_file_path}")
            return
        
        # Extract manufacturer and part number from each file path
        csv_data = []
        for file_path in cad_data:
            parts = file_path.split('/')
            if len(parts) >= 2:
                manufacturer = parts[0]
                # Extract part number by removing file extension
                part_number = os.path.splitext(parts[1])[0]
                csv_data.append([manufacturer, part_number])
        
        # Write to CSV file
        try:
            with open(csv_file_path, 'w', newline='') as csv_file:
                # Configure CSV writer to quote all fields
                csv_writer = csv.writer(csv_file, quoting=csv.QUOTE_ALL)
                # Write header
                csv_writer.writerow(['manufacturer', 'pn'])
                # Write data rows
                csv_writer.writerows(csv_data)
            
            print(f"Successfully created CSV file: {csv_file_path}")
            print(f"Exported {len(csv_data)} records")
        except Exception as e:
            print(f"Error writing to CSV file: {e}")

    if __name__ == "__main__":
        main()

[no-cd]
@list-stp-by-size csv_file="./cads.csv":
    #!/usr/bin/env -S uv run --script

    import csv
    import os
    from pathlib import Path
    import sys

    def main():
        csv_file_path = Path("{{csv_file}}")
        stp_base_dir = Path("/home/maccou/work/3d/data/3D/stp")
        
        if not csv_file_path.exists():
            print(f"Error: CSV file {csv_file_path} not found.")
            return
            
        if not stp_base_dir.exists():
            print(f"Error: STP base directory {stp_base_dir} not found.")
            return
            
        # Read the CSV file
        file_info = []
        try:
            with open(csv_file_path, 'r', newline='') as f:
                reader = csv.reader(f)
                # Skip header
                next(reader, None)
                
                for row in reader:
                    if len(row) >= 2:
                        manufacturer = row[0].strip('"')
                        part_number = row[1].strip('"')
                        
                        # Check for both .stp and .STP extensions
                        potential_paths = [
                            stp_base_dir / manufacturer / f"{part_number}.stp",
                            stp_base_dir / manufacturer / f"{part_number}.STP"
                        ]
                        
                        for file_path in potential_paths:
                            if file_path.exists():
                                size = file_path.stat().st_size
                                file_info.append((file_path, size))
                                break
                        
        except Exception as e:
            print(f"Error reading CSV file: {e}")
            return
            
        if not file_info:
            print("No matching STP files found.")
            return
            
        file_info.sort(key=lambda x: -x[1])
        
        # Print files with their sizes
        print("\nSTP Files sorted by size (smallest to largest):\n")
        print(f"{'File Path':<60} {'Size':<15}")
        print("-" * 75)
        
        for file_path, size in file_info:
            size_str = format_size(size)
            print(f"{str(file_path):<60} {size_str:<15}")
            
        print(f"\nTotal files: {len(file_info)}")
        
    def format_size(size_bytes):
        """Format file size in human-readable format"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024 or unit == 'GB':
                return f"{size_bytes:.2f} {unit}"
            size_bytes /= 1024

    if __name__ == "__main__":
        main()
