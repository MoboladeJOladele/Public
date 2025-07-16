#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JQ="$DIR/jq"
META_PATH="/usr/local/include/lib_Code/code.meta"

echo "Uninstalling code.h..."

# --- Check if metadata exists ---
if [ ! -f "$META_PATH" ]; then
    echo "Metadata file not found: $META_PATH"
    exit 1
fi

# --- Parse metadata using local jq ---
os_type=$("$JQ" -r '.os_type' "$META_PATH")
sub_os=$("$JQ" -r '.sub_os' "$META_PATH")
lib_dir=$("$JQ" -r '.lib_dir' "$META_PATH")
header_path=$("$JQ" -r '.header_path' "$META_PATH")
version=$("$JQ" -r '.version' "$META_PATH")
injected_paths=$("$JQ" -r '.injected_paths[]' "$META_PATH")

# --- Remove injected headers ---
for path in $injected_paths; do
    if [ -f "$path/code.h" ]; then
        sudo rm -f "$path/code.h"
        echo "Removed $path/code.h"
    fi
done

# --- Remove main header ---
if [ -f "$header_path" ]; then
    sudo rm -f "$header_path"
    echo "Removed $header_path"
fi

# --- Remove symlink ---
if [ -L "/usr/local/include/code.h" ]; then
    sudo rm -f "/usr/local/include/code.h"
    echo "Removed symlink: /usr/local/include/code.h"
fi

# --- Remove lib directory ---
if [ -d "$lib_dir" ]; then
    sudo rm -rf "$lib_dir"
    echo "Removed directory: $lib_dir"
fi

# --- Remove metadata ---
sudo rm -f "$META_PATH"
echo "Removed metadata: $META_PATH"

echo "Uninstallation complete."
