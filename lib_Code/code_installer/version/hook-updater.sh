#!/bin/bash

# === CONFIG ===
UPDATE_SCRIPT="/usr/local/include/lib_Code/version/code-update.sh"
HOOK_LINE="bash \"$UPDATE_SCRIPT\" >/dev/null 2>&1 &"

echo "Hooking code-update.sh into shell startup..."

# Detect default shell
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
elif [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
else
    echo "Unsupported shell: $SHELL_NAME"
    exit 1
fi

# Check and append if not already present
if grep -Fxq "$HOOK_LINE" "$RC_FILE"; then
    echo "code-update.sh is already hooked into $RC_FILE"
else
    echo "$HOOK_LINE" >> "$RC_FILE"
    echo "Added auto-updater hook to $RC_FILE"
fi
