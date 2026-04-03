#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CSPELL_URL="https://raw.githubusercontent.com/autowarefoundation/autoware-spell-check-dict/main/.cspell.json"

cd "$WORKSPACE_DIR"

echo "Refreshing CSpell configuration..."
curl -fsSL "$CSPELL_URL" -o .cspell.json

if command -v yarn >/dev/null 2>&1; then
    echo "Refreshing Tier IV CSpell dictionaries..."
    yarn global add https://github.com/tier4/cspell-dicts >/dev/null
fi
