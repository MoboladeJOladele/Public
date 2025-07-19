#!/bin/bash

set -e

# === CONFIG ===
DOWNLOAD_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/code.h"
VERSION_URL="https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/codeh.version"
LIB_DIR="/usr/local/share/CODE_H"
HEADER_PATH="/usr/local/include/code.h"
VERSION_PATH="$LIB_DIR/codeh.version"
META_PATH="$LIB_DIR/code.meta.json"

# Create working directory
sudo mkdir -p "$LIB_DIR"

# Download header and version
echo "Downloading code.h..."
curl -fsSL "$DOWNLOAD_URL" -o "/tmp/code.h"
curl -fsSL "$VERSION_URL" -o "/tmp/codeh.version"


sudo cp "/tmp/code.h" "$HEADER_PATH"
sudo cp "/tmp/codeh.version" "$VERSION_PATH"
rm "/tmp/code.h"
rm "/tmp/codeh.version"
echo "Downloaded to: $HEADER_PATH"

# Compiler info
if command -v gcc >/dev/null; then
    COMPILER="$(gcc --version | head -n1)"
elif command -v clang >/dev/null; then
    COMPILER="$(clang --version | head -n1)"
else
    COMPILER="Unknown"
fi

# Version info
VERSION="Unknown"
if [ -f "$VERSION_PATH" ]; then
    VERSION=$(head -n1 "$VERSION_PATH")
fi

# Copy update and daemon scripts
SCRIPT_DIR="$PWD/upp3"
for script in update-code.sh code-daemon.py; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        sudo cp "$SCRIPT_DIR/$script" "$LIB_DIR/$script"
        echo "Downloaded $script to: $LIB_DIR/$script"
    fi
done

# Install daemon (already downloaded earlier)
DAEMON_PATH="$LIB_DIR/code-daemon.py"
CRON_JOB="0 */2 * * * /usr/bin/python3 $DAEMON_PATH >/dev/null 2>&1"

echo "Installing daemon..."
sudo chmod +x "$DAEMON_PATH"

# Register cron job if not already present
if ! crontab -l 2>/dev/null | grep -q "$DAEMON_PATH"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job set to run every 2 hours."
else
    echo "Cron job already exists."
fi

# Copy jq file
sudo cp "jq" "$LIB_DIR/jq"

# Metadata JSON
cat <<EOF | sudo tee "$META_PATH" > /dev/null
{
  "os_type": "$(uname -s)",
  "sub_os": "None",
  "compiler": "$COMPILER",
  "lib_dir": "$LIB_DIR",
  "header_path": "$TARGET_HEADER",
  "injected_paths": ["/usr/local/include"],
  "wsl_paths": ["$TARGET_HEADER"],
  "version": "$VERSION"
}
EOF

echo "Metadata saved to: $META_PATH"
echo "Installation complete."
