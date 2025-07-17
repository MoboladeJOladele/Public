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

# Remove injected header copies
foreach ($path in $meta.injected_paths) {
    $full = Join-Path $path "code.h"
    if (Test-Path $full) {
        Remove-Item $full -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $full"
    }
}

# Remove header and lib dir
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
    # Log all files we intend to remove (from metadata)
    Write-Host "Cleaning up WSL files..."
    foreach ($wslFile in $meta.wsl_paths) {
        Write-Host "Queued for removal: $wslFile"
    }

    # WSL base folder
    $wslFolder = "/usr/local/lib_Code/"

    # Build unified rm command: all files + the parent folder
    $rmTargets = ($meta.wsl_paths + $wslFolder) | ForEach-Object { "'$_'" }
    $rmCmd = "sudo rm -rf " + ($rmTargets -join " ")

    # Single sudo call for all cleanup
    wsl bash -c "$rmCmd"
    Write-Host "Removed from WSL: All tracked files and $wslFolder"

    # Clean .bashrc
    Write-Host "Cleaning WSL .bashrc..."
    try {
        wsl sed -i '/code-update.sh/d' ~/.bashrc
        wsl sed -i '/CODE_LIB_PATH/d' ~/.bashrc
        wsl sed -i '/Auto-update code\.h/d' ~/.bashrc
        Write-Host "Removed bashrc hook"
    } catch {
        Write-Host "Could not clean .bashrc"
    }
}

# Remove Windows Scheduled Task
$TaskName = "CodeHeaderAutoUpdate"
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Removed Windows Scheduled Task: $TaskName"
}

Write-Host "`nUninstallation complete."
Read-Host "Press Enter to exit"
