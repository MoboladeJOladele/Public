#!/bin/bash

set -e

# === CONFIG ===
URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
VERSION_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
LIB_DIR="/usr/local/include/lib_Code"
HEADER_PATH="$LIB_DIR/code.h"
SYMLINK="/usr/local/include/code.h"
META_PATH="$LIB_DIR/code.meta"

echo "Downloading code.h..."
sudo mkdir -p "$LIB_DIR"
sudo curl -fsSL "$URL" -o "$HEADER_PATH"
sudo chmod 644 "$HEADER_PATH"
sudo ln -sf "$HEADER_PATH" "$SYMLINK"

# === Detect OS/SubOS ===
OS_TYPE="$(uname -s)"
SUB_OS="None"
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    SUB_OS="WSL"
fi

# === Compiler Detection ===
if command -v gcc >/dev/null; then
    COMPILER="gcc $(gcc --version | head -n1)"
elif command -v clang >/dev/null; then
    COMPILER="clang $(clang --version | head -n1)"
else
    COMPILER="Unknown"
fi

# === Version Info ===
VERSION="$(curl -fsSL "$VERSION_URL" || echo Unknown)"

# === Write Metadata ===
echo "Writing metadata..."
cat <<EOF | sudo tee "$META_PATH" >/dev/null
{
  "os_type": "$OS_TYPE",
  "sub_os": "$SUB_OS",
  "compiler": "$COMPILER",
  "env_var": null,
  "lib_dir": "$LIB_DIR",
  "header_path": "$HEADER_PATH",
  "injected_paths": ["/usr/local/include"],
  "version": "$VERSION"
}
EOF

echo "code.h installed to $HEADER_PATH"
echo "Symlink created at $SYMLINK"
