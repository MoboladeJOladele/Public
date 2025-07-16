#!/bin/bash

# === CONFIG ===
URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/version/code.version"
REMOTE_HEADER_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
TARGET_DIR="/usr/local/include/lib_Code"
HEADER_FILE="$TARGET_DIR/code.h"
LOCAL_VERSION_FILE="$TARGET_DIR/code.version"

# === Ensure directory exists
if [ ! -d "$TARGET_DIR" ]; then
    exit 0
fi

# === Fetch remote version
remote_version=$(curl -fsSL "$URL")
if [ -z "$remote_version" ]; then
    exit 0
fi

# === Fetch local version
if [ -f "$LOCAL_VERSION_FILE" ]; then
    local_version=$(cat "$LOCAL_VERSION_FILE")
else
    local_version="0.0.0"
fi

# === Compare and update if necessary
if [ "$remote_version" != "$local_version" ]; then
    curl -fsSL "$REMOTE_HEADER_URL" -o "$HEADER_FILE"
    echo "$remote_version" | sudo tee "$LOCAL_VERSION_FILE" > /dev/null
fi
