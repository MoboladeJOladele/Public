#!/bin/bash

set -e
META_PATH="./lib_Code/code.meta"
JQ="./lib_Code/code_installer/jq"

if [ ! -f "$META_PATH" ]; then
    echo "Metadata not found at: $META_PATH"
    exit 1
fi

if [ ! -x "$JQ" ]; then
    echo "jq not found at: $JQ"
    exit 1
fi

header_path=$("$JQ" -r '.header_path' "$META_PATH")
injected_paths=$("$JQ" -r '.injected_paths[]' "$META_PATH")
lib_dir=$("$JQ" -r '.lib_dir' "$META_PATH")
wsl_paths=$("$JQ" -r '.wsl_paths[]' "$META_PATH")

echo "Uninstalling code.h..."

# Remove injected header copies
for p in $injected_paths; do
    if [ -f "$p/code.h" ]; then
        sudo rm -f "$p/code.h" && echo "Removed: $p/code.h"
    fi
done

# Remove global WSL header
[ -f "$header_path" ] && sudo rm -f "$header_path" && echo "Removed: $header_path"
[ -f "/usr/local/include/code.h" ] && sudo rm -f "/usr/local/include/code.h" && echo "Removed: WSL global header"

# Remove lib directory and metadata
[ -d "$lib_dir" ] && sudo rm -rf "$lib_dir" && echo "Removed: $lib_dir"
[ -f "$META_PATH" ] && sudo rm -f "$META_PATH" && echo "Removed: $META_PATH"

# Remove any other WSL-specific paths listed
for p in $wsl_paths; do
    sudo rm -f "$p" && echo "Removed from WSL: $p"
done

# Remove .bashrc injections
echo "Cleaning .bashrc..."
sed -i '/code-update\.sh/d' ~/.bashrc && echo "Removed code-update.sh injection"
sed -i '/CODE_LIB_PATH/d' ~/.bashrc && echo "Removed CODE_LIB_PATH export"
sed -i '/Auto-update code\.h/d' ~/.bashrc && echo "Removed auto-update comment"

echo "Uninstallation complete."
