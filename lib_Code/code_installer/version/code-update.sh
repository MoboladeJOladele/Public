#!/bin/bash

# --- CONFIG ---
CODE_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
VERSION_FILE="$(dirname "$0")/code.version"
LOCAL_HEADER="$(dirname "$0")/../lib_Code/code.h"
TEMP_FILE="/tmp/code.h"
WSL_HEADER="/usr/local/include/code.h"
WIN_HEADER="/mnt/c/ProgramData/lib_Code/code.h"

# --- Step 1: Get remote and local versions ---
REMOTE_VERSION=$(curl -s "$REMOTE_VERSION_URL")
LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null)

if [ -z "$REMOTE_VERSION" ]; then
    echo "ERROR: Could not fetch remote version"
    exit 1
fi

if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    echo "Updating code.h to version $REMOTE_VERSION"

    # --- Step 2: Download new code.h ---
    curl -s -o "$TEMP_FILE" "$CODE_URL" || {
        echo "Failed to download code.h"
        exit 1
    }

    # --- Step 3a: Update local lib_Code/code.h ---
    cp "$TEMP_FILE" "$LOCAL_HEADER" 2>/dev/null || echo "Could not update local lib_Code/code.h"

    # --- Step 3b: Update WSL global include ---
    if [ ! -f "$WSL_HEADER" ]; then
        sudo mkdir -p "$(dirname "$WSL_HEADER")"
    fi
    sudo cp "$TEMP_FILE" "$WSL_HEADER" 2>/dev/null || echo "Could not update WSL include path"

    # --- Step 3c: Update Windows copy if accessible ---
    if [ -f "$WIN_HEADER" ]; then
        cp "$TEMP_FILE" "$WIN_HEADER" 2>/dev/null || echo "Could not update Windows ProgramData copy"
    fi

    # --- Step 4: Save updated version ---
    echo "$REMOTE_VERSION" > "$VERSION_FILE" || echo "WARNING: Failed to update version file"

    echo "code.h updated successfully"
else
    echo "Already up to date (version $LOCAL_VERSION)"
fi

# --- Step 5: Cleanup ---
rm -f "$TEMP_FILE"
