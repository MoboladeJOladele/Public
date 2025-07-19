# uninstall-code.ps1 — Uninstalls using ./CODE_H/code.meta

$LocalMeta = "$env:ProgramData\CODE_H\code.meta.json"

if (!(Test-Path $LocalMeta)) {
    Write-Host "No metadata file found at: $LocalMeta"
    exit 1
}

$meta = Get-Content $LocalMeta | ConvertFrom-Json
Write-Host "Uninstalling code.h..."

# Remove from CODE_PATH
$envVar = $meta.env_var
if ($envVar -and $meta.lib_dir) {
    foreach ($scope in @("User", "Machine")) {
        $existing = [Environment]::GetEnvironmentVariable($envVar, $scope)
        if ($existing -and $existing -like "*$($meta.lib_dir)*") {
            [Environment]::SetEnvironmentVariable($envVar, $null, $scope)
            Write-Host "Deleted $envVar variable from ($scope scope)"
        }
    }
}

# Remove injected copies
foreach ($path in $meta.injected_paths) {
    $full = Join-Path $path "code.h"
    if (Test-Path $full) {
        Remove-Item $full -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $full"
    }
}

# Remove lib dir
if (Test-Path $meta.lib_dir) {
    Remove-Item $meta.lib_dir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed directory: $($meta.lib_dir)"
}

# Remove from WSL
if ($meta.sub_os -eq "WSL" -or $meta.wsl_paths) {
    foreach ($wslFile in $meta.wsl_paths) {
        wsl sudo rm -f "$wslFile"
        Write-Host "Removed from WSL: $wslFile"
    }
}

# Disable Auto Update Script
Write-Host "Removing daemon task..."

$TaskName = "CodeHDaemon"
try {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Host "Daemon task '$TaskName' removed successfully."
    } else {
        Write-Host "No daemon task named '$TaskName' found."
    }
}
catch {
    Write-Host "Error removing daemon task: $_"
}

Write-Host "`nUninstallation complete."
Read-Host "Press Enter to exit"