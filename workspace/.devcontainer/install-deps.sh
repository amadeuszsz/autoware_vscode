#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$WORKSPACE_DIR"

if ! command -v rosdep >/dev/null 2>&1; then
    echo "rosdep not available in this container. Skipping dependency install."
    exit 0
fi

if [[ ! -d src ]] || [[ -z $(find src -mindepth 1 -maxdepth 1 -print -quit) ]]; then
    echo "Workspace src/ is empty. Skipping dependency install."
    exit 0
fi

echo "Updating rosdep indexes..."
rosdep update

echo "Installing ROS dependencies..."
sudo apt update
rosdep install --from-paths src --ignore-src -yr
