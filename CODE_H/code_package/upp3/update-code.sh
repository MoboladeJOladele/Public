#!/bin/bash

# === CONFIG ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEADER_PATH="/usr/local/include/code.h"
VERSION_PATH="$SCRIPT_DIR/codeh.version"
META_PATH="$SCRIPT_DIR/code.meta.json"

REMOTE_VERSION_URL="https://github.com/MoboladeJOladele/Public/blob/main/CODE_H/code.version"
REMOTE_HEADER_URL="https://github.com/MoboladeJOladele/Public/blob/main/CODE_H/code.h"

# Fetch remote version
remote_version=$(curl -fsSL "$REMOTE_VERSION_URL" 2>/dev/null)
[ -z "$remote_version" ] && exit 0

# Read local version
if [ -f "$VERSION_PATH" ]; then
    local_version=$(cat "$VERSION_PATH")
else
    local_version="none"
fi

# Compare and update
if [ "$remote_version" != "$local_version" ]; then
    curl -fsSL "$REMOTE_HEADER_URL" -o "$HEADER_PATH" || exit 0

    echo "$remote_version" > "$VERSION_PATH"

    # Update code.meta.json
    if [ -f "$META_PATH" ]; then
        jq --arg ver "$remote_version" '.version = $ver' "$META_PATH" > "$META_PATH.tmp" && mv "$META_PATH.tmp" "$META_PATH"
    fi
fi

exit 0
