# --- CONFIG ---
$CodeURL         = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
$RemoteVersionURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
$ScriptDir       = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile     = Join-Path $ScriptDir "code.version"
$LocalHeader     = Join-Path $ScriptDir "..\lib_Code\code.h"
$GlobalHeader    = "C:\ProgramData\lib_Code\code.h"
$TempFile        = "$env:TEMP\code.h"

# --- Step 1: Get remote version ---
try {
    $RemoteVersion = Invoke-RestMethod -Uri $RemoteVersionURL -UseBasicParsing
} catch {
    Write-Host "ERROR: Could not fetch remote version"
    exit 1
}

# --- Step 2: Get local version ---
$LocalVersion = if (Test-Path $VersionFile) {
    Get-Content $VersionFile -ErrorAction SilentlyContinue | Select-Object -First 1
} else {
    ""
}

# --- Step 3: Compare versions ---
if ($RemoteVersion -ne $LocalVersion) {
    Write-Host "Updating code.h to version $RemoteVersion"

    # --- Step 4: Download new code.h ---
    try {
        Invoke-WebRequest -Uri $CodeURL -OutFile $TempFile -UseBasicParsing
    } catch {
        Write-Host "Failed to download code.h"
        exit 1
    }

    # --- Step 5a: Update local lib_Code/code.h ---
    try {
        Copy-Item -Path $TempFile -Destination $LocalHeader -Force
    } catch {
        Write-Host "Could not update local lib_Code copy"
    }

    # --- Step 5b: Update C:\ProgramData copy ---
    try {
        Copy-Item -Path $TempFile -Destination $GlobalHeader -Force
    } catch {
        Write-Host "Could not update global ProgramData copy"
    }

    # --- Step 6: Save new version ---
    try {
        Set-Content -Path $VersionFile -Value $RemoteVersion -Encoding ASCII
    } catch {
        Write-Host "WARNING: Failed to update version file"
    }

    Write-Host "code.h updated successfully"
} else {
    Write-Host "Already up to date (version $LocalVersion)"
}

# --- Step 7: Clean up ---
Remove-Item -Path $TempFile -Force -ErrorAction SilentlyContinue
