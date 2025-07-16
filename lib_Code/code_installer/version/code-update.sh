#!/bin/bash

# === CONFIG ===
LIB_DIR="/usr/local/include/lib_Code"
HEADER_PATH="$LIB_DIR/code.h"
VERSION_PATH="$LIB_DIR/version/code.version"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
REMOTE_HEADER_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"

# Ensure paths exist
mkdir -p "$LIB_DIR/version"

# Fetch remote version
remote_version=$(curl -fsSL "$REMOTE_VERSION_URL" 2>/dev/null)
if [ -z "$remote_version" ]; then
    exit 0  # Silent exit if failed
fi

# Read local version
if [ -f "$VERSION_PATH" ]; then
    local_version=$(cat "$VERSION_PATH")
else
    local_version="none"
fi

# Compare versions
if [ "$remote_version" != "$local_version" ]; then
    curl -fsSL "$REMOTE_HEADER_URL" -o "$HEADER_PATH" && \
    echo "$remote_version" > "$VERSION_PATH"
fi

exit 0
