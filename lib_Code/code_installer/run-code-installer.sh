#!/bin/bash

install_unix() {
    echo "🔧 Running Linux/macOS installer..."
    bash ./install-code.sh
}

install_windows() {
    echo "🪟 Running Windows installer..."
    powershell.exe -ExecutionPolicy Bypass -File install-code.ps1
}

is_wsl() {
    grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null
}

is_linux() {
    uname -s | grep -qi linux
}

is_mac() {
    uname -s | grep -qi darwin
}

run_all() {
    if is_linux || is_mac || is_wsl; then
        install_unix
    fi

    if [ -n "$WINDIR" ] || [[ "$(uname -a)" == *"NT"* ]]; then
        install_windows
    fi
}

run_all