#!/bin/bash

TARGET_DIR="/usr/local/include/lib_Code"
SYMLINK="/usr/local/include/code.h"

echo "Uninstalling code.h from Linux/macOS..."

if [ -L "$SYMLINK" ] || [ -f "$SYMLINK" ]; then
    sudo rm -f "$SYMLINK"
    echo "Removed symlink $SYMLINK"
fi

if [ -d "$TARGET_DIR" ]; then
    sudo rm -rf "$TARGET_DIR"
    echo "Removed directory $TARGET_DIR"
fi

echo "Uninstallation complete (Linux/macOS)"