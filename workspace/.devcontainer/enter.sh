#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "$(dirname "$SCRIPT_DIR")")"

if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "Container '$CONTAINER_NAME' is not running."
    echo "Open the workspace in a devcontainer first, then retry."
    exit 1
fi

docker exec -it "$CONTAINER_NAME" bash
