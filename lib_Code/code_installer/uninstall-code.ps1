# uninstall-code.ps1 — Uninstalls using ./lib_Code/code.meta

$LocalMeta = Join-Path $PSScriptRoot "lib_Code\code.meta"

if (!(Test-Path $LocalMeta)) {
    Write-Host "No metadata file found at: $LocalMeta"
    exit 1
}

$meta = Get-Content $LocalMeta | ConvertFrom-Json
Write-Host "Uninstalling code.h..."

# Remove from INCLUDE
$envVar = $meta.env_var
if ($envVar -and $meta.lib_dir) {
    $existing = [Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine)
    if ($existing -like "*$($meta.lib_dir)*") {
        $updated = ($existing -split ";" | Where-Object { $_ -ne $meta.lib_dir }) -join ";"
        [Environment]::SetEnvironmentVariable($envVar, $updated, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Removed $($meta.lib_dir) from $envVar"
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

# Remove header + lib dir
if (Test-Path $meta.header_path) {
    Remove-Item $meta.header_path -Force -ErrorAction SilentlyContinue
    Write-Host "Removed header: $($meta.header_path)"
}
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

Write-Host "`nUninstallation complete."
