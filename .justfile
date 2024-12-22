set dotenv-load := false
set export := true

project-name := "new-project"
gitignore-path := "$HOME/dotfiles/git/gitignore"

[no-cd]
@_default:
    just --list

# Create a new library with src layout. Used for packaging.
[no-cd]
@new-library name=project-name:
    mkdir {{ name }}
    just _bootstrap library {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow
    cp {{ gitignore-path }} {{ name }}/.gitignore

# Create a new application. Useful for web apps, scripts, or CLIs.
[no-cd]
@new-app name=project-name:
    mkdir {{ name }}
    just _bootstrap app {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow
    cp {{ gitignore-path }} {{ name }}/.gitignore

    echo "Installing UV"
    just _install-uv

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

