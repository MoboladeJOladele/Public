#!/bin/bash

# === CONFIG ===
URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/refs/heads/main/lib_Code/code.h"
TARGET_DIR="/usr/local/include/lib_Code"
HEADER_FILE="$TARGET_DIR/code.h"
SYMLINK="/usr/local/include/code.h"

echo "📥 Downloading code.h..."

if [ ! -d "$TARGET_DIR" ]; then
    sudo mkdir -p "$TARGET_DIR"
fi

sudo curl -fsSL "$URL" -o "$HEADER_FILE"
sudo chmod 644 "$HEADER_FILE"

if [ -L "$SYMLINK" ] || [ -f "$SYMLINK" ]; then
    sudo rm -f "$SYMLINK"
fi

sudo ln -s "$HEADER_FILE" "$SYMLINK"

echo "✅ code.h installed to $HEADER_FILE"
echo "🔗 Symlink created at $SYMLINK"
echo "🎯 You can now #include <code.h>"