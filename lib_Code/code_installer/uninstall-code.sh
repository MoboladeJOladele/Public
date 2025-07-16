#!/bin/bash

TARGET_DIR="/usr/local/include/lib_Code"
SYMLINK="/usr/local/include/code.h"
INJECT_LINE='[ -x /usr/local/include/lib_Code/version/code-update.sh ] && /usr/local/include/lib_Code/version/code-update.sh'

echo "Uninstalling code.h from Linux/macOS..."

# Remove symlink
if [ -L "$SYMLINK" ] || [ -f "$SYMLINK" ]; then
    sudo rm -f "$SYMLINK"
    echo "Removed symlink $SYMLINK"
fi

# Remove directory
if [ -d "$TARGET_DIR" ]; then
    sudo rm -rf "$TARGET_DIR"
    echo "Removed directory $TARGET_DIR"
fi

# Remove auto-update line from .bashrc or .zshrc
PROFILE="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && PROFILE="$HOME/.zshrc"

if grep -qF "$INJECT_LINE" "$PROFILE"; then
    sed -i "\|$INJECT_LINE|d" "$PROFILE"
    echo "Removed auto-update line from $PROFILE"
fi

echo "Uninstallation complete (Linux/macOS)"
