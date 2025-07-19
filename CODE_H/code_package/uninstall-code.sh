#!/bin/bash

set -e

# === CONFIG ===
META_PATH="/usr/local/share/CODE_H/code.meta.json"
JQ="/usr/local/share/CODE_H/jq"

if [ ! -f "$META_PATH" ]; then
    echo "Metadata not found at: $META_PATH"
    exit 1
fi

if [ ! -x "$JQ" ]; then
    echo "jq not found at: $JQ"
    exit 1
fi

echo "Reading metadata from: $META_PATH"

header_path=$("$JQ" -r '.header_path' "$META_PATH")
injected_paths=$("$JQ" -r '.injected_paths[]' "$META_PATH")
lib_dir=$("$JQ" -r '.lib_dir' "$META_PATH")
wsl_paths=$("$JQ" -r '.wsl_paths[]' "$META_PATH")

echo "Uninstalling code.h..."

# Remove from injected paths
for p in $injected_paths; do
    sudo rm -f "$p/code.h" && echo "Removed: $p/code.h"
done

# Remove main header
[ -f "$header_path" ] && sudo rm -f "$header_path" && echo "Removed: $header_path"

# Remove /usr/local/include/code.h fallback
[ -f "/usr/local/include/code.h" ] && sudo rm -f "/usr/local/include/code.h" && echo "Removed fallback: /usr/local/include/code.h"

# Remove daemon/update scripts + meta dir
[ -d "$lib_dir" ] && sudo rm -rf "$lib_dir" && echo "Removed: $lib_dir"

# Remove WSL paths
for p in $wsl_paths; do
    sudo rm -f "$p" && echo "Removed from WSL: $p"
done

DAEMON_PATH="/usr/local/share/CODE_H/code-daemon.py"

# Remove cron job
echo "Cleaning up cron job..."
crontab -l 2>/dev/null | grep -v "$DAEMON_PATH" | crontab -

echo "Uninstallation complete."
