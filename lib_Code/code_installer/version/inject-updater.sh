#!/bin/bash

# === Auto-hook WSL Terminal for code.h updates ===

BASHRC="$HOME/.bashrc"
HOOK_LINE='bash /usr/local/lib_Code/version/code-update.sh >/dev/null 2>&1 &'

# Add new hook if not already present
if ! grep -Fxq "$HOOK_LINE" "$BASHRC"; then
    echo -e "\n# Auto-update code.h on terminal start" >> "$BASHRC"
    echo "$HOOK_LINE" >> "$BASHRC"
    echo "code-update.sh hooked into .bashrc"
else
    echo "code-update.sh is already hooked into .bashrc"
fi
