# uninstall-code.ps1

$MetaPath = "$env:ProgramData\lib_Code\code.meta"

if (-Not (Test-Path $MetaPath)) {
    Write-Host "No metadata file found at $MetaPath"
    exit 1
}

# Load metadata
$meta = Get-Content $MetaPath | ConvertFrom-Json
Write-Host "Uninstalling code.h..."
$removed = @()

# Remove from ENV variable
$envVar = $meta.env_var
if ($envVar -and $meta.lib_dir) {
    $existing = [Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine)
    if ($existing -like "*$($meta.lib_dir)*") {
        $updated = ($existing -split ";" | Where-Object { $_ -ne $meta.lib_dir }) -join ";"
        [Environment]::SetEnvironmentVariable($envVar, $updated, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Removed $($meta.lib_dir) from $envVar"
    }
}

# Remove injected header copies
foreach ($path in $meta.injected_paths) {
    $full = Join-Path $path "code.h"
    if (Test-Path $full) {
        Remove-Item $full -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $full"
        $removed += $full
    }
}

# Delete main header and lib_Code dir
if (Test-Path $meta.header_path) {
    Remove-Item $meta.header_path -Force -ErrorAction SilentlyContinue
    Write-Host "Removed: $($meta.header_path)"
}
if (Test-Path $meta.lib_dir) {
    Remove-Item $meta.lib_dir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed directory: $($meta.lib_dir)"
}

# Cleanup
if (Test-Path $MetaPath) {
    Remove-Item $MetaPath -Force
    Write-Host "Removed metadata file"
}

# --- 📦 WSL Uninstall Phase ---
if ($meta.sub_os -eq "WSL") {
    Write-Host "`n WSL detected. Attempting WSL uninstallation..."

    # Get current script directory and convert it to WSL path
    $CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $WSLPath = $CurrentDir -replace "^([A-Za-z]):\\", "/mnt/$($matches[1].ToLower())/" -replace "\\", "/"

    $WSLScript = "$WSLPath/uninstall-code.sh"
    $WSLCommand = "bash $WSLScript"

    Write-Host "Executing: wsl $WSLCommand"
    wsl.exe $WSLCommand

    Write-Host "WSL uninstallation completed."
}

Write-Host "`n Full uninstallation complete."
