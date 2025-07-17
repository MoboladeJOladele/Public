#!/bin/bash

set -e

URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
LIB_DIR="./lib_Code"
HEADER_PATH="$LIB_DIR/code.h"
TARGET_HEADER="/usr/local/include/code.h"
META_PATH="$LIB_DIR/code.meta"
VERSION_FILE="$LIB_DIR/version/code.version"

# Download if missing
if [ ! -f "$HEADER_PATH" ]; then
    mkdir -p "$LIB_DIR"
    echo "Downloading code.h..."
    curl -fsSL "$URL" -o "$HEADER_PATH"
fi

# Deploy to WSL include
sudo cp "$HEADER_PATH" "$TARGET_HEADER"
echo "Installed to $TARGET_HEADER"

# Compiler
if command -v gcc >/dev/null; then
    COMPILER="gcc $(gcc --version | head -n1)"
elif command -v clang >/dev/null; then
    COMPILER="clang $(clang --version | head -n1)"
else
    COMPILER="Unknown"
fi

# Version
VERSION="Unknown"
if [ -f "$VERSION_FILE" ]; then
    VERSION=$(head -n1 "$VERSION_FILE")
fi

# === Inject updater into shell startup
INJECT_SCRIPT="$(dirname "$0")/version/inject-updater.sh"
if [ -f "$INJECT_SCRIPT" ]; then
    bash "$INJECT_SCRIPT"
fi

# === Inject updater into shell startup
INJECT_SCRIPT="$(dirname "$0")/version/inject-updater.sh"
if [ -f "$INJECT_SCRIPT" ]; then
    bash "$INJECT_SCRIPT"
fi

# Metadata
cat <<EOF | tee "$META_PATH" >/dev/null
{
  "os_type": "$(uname -s)",
  "sub_os": "None",
  "compiler": "$COMPILER",
  "env_var": null,
  "lib_dir": "$LIB_DIR",
  "header_path": "$TARGET_HEADER",
  "injected_paths": ["/usr/local/include"],
  "wsl_paths": ["$TARGET_HEADER"],
  "version": "$VERSION"
}
EOF

echo "Metadata written to: $META_PATH"
