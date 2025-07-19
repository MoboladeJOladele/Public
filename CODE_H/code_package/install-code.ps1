# install-code.ps1 — Installs code.h from Temp Folder or downloads if needed

$DownloadURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/code.h"
$VersionURL  = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/codeh.version"

#  Local paths
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TargetDir   = "$env:ProgramData\CODE_H"
$TempFolder  = Join-Path $env:TEMP "CODE_H_TEMP"   # ✅ Temp directory

#  Ensure temp folder exists
if (!(Test-Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder | Out-Null
}

$HeaderFile   = Join-Path $TempFolder "code.h"
$VersionFile  = Join-Path $TempFolder "codeh.version"

Write-Host "Downloading code.h..."
Invoke-WebRequest -Uri $DownloadURL -OutFile $HeaderFile -UseBasicParsing
Invoke-WebRequest -Uri $VersionURL  -OutFile $VersionFile -UseBasicParsing
Write-Output "Downloaded header to: $HeaderFile"

# === Add CODE_PATH env var
$IncludeVar  = "CODE_PATH"
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -notlike "*$TargetDir*") {
    $new = if ($existing) { "$existing;$TargetDir" } else { "$TargetDir" }
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Added CODE_PATH environment variable"
}

# Ensure ProgramData folder exists
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# Copy version file to ProgramData folder
$version_path = Join-Path $TargetDir "codeh.version"
Copy-Item $VersionFile -Destination $version_path -Force

# --- Copy daemon and update scripts from download folder ---
$GetUpp3 = Join-Path $ScriptRoot "upp3"
$ScriptsToCopy = @("code-daemon.py", "update-code.ps1")

foreach ($script in $ScriptsToCopy) {
    $src  = Join-Path $GetUpp3 $script
    $dest = Join-Path $TargetDir $script
    if (Test-Path $src) {
        Copy-Item $src -Destination $dest -Force
    } else {
        Write-Warning "Missing script: $script in $GetUpp3"
    }
}

# Create metadata file
$MetaPath    = Join-Path $TargetDir "code.meta.json"

# === Inject into known Windows compilers
$Injected = @()
$MinGWPaths = @("C:\MinGW", "C:\MinGW64", "C:\Program Files\mingw-w64", "C:\mingw64")
foreach ($path in $MinGWPaths) {
    $includeDir = Join-Path $path "include"
    if (Test-Path $includeDir) {
        Copy-Item -Path $HeaderFile -Destination "$includeDir\code.h" -Force
        $Injected += $includeDir
        Write-Host "Injected into MinGW at $includeDir"
    }
}

$VCPaths = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Directory -Filter "include" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*VC\Tools\MSVC\*\include" }
foreach ($vc in $VCPaths) {
    Copy-Item -Path $HeaderFile -Destination "$($vc.FullName)\code.h" -Force
    $Injected += $vc.FullName
    Write-Host "Injected into MSVC at $($vc.FullName)"
}

# === Deploy to WSL
$WSLPaths = @()
if (Test-Path "$env:windir\System32\wsl.exe") {
    Write-Host "Deploying to WSL..."

    try {
        $HeaderFileFull = (Resolve-Path $HeaderFile).Path
        $headerWSL = wsl wslpath -a -u "`"$HeaderFileFull`""
        $headerWSL = $headerWSL.Trim()

        $cpSuccess = $true
        try {
            wsl bash -c "sudo cp '$headerWSL' '/usr/local/include/code.h'"
            Write-Host "WSL cp: success"
        } catch {
            $cpSuccess = $false
        }

        if (-not $cpSuccess) {
            try {
                Get-Content -Raw -Encoding Byte "$HeaderFileFull" | wsl bash -c "cat | sudo tee /usr/local/include/code.h >/dev/null"
                Write-Host "Fallback (cat) success: code.h deployed to WSL"
            } catch { }
        }

        $WSLPaths += "/usr/local/include/code.h"
    } catch {
        Write-Host "Failed to deploy to WSL: $_"
    }
}

# Install daemon (already copied earlier)
$TaskName = "CodeHDaemon"
$DaemonPath = Join-Path $TargetDir "code-daemon.ps1"

Write-Host "Installing daemon task..."

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$DaemonPath`""
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date `
    -RepetitionInterval (New-TimeSpan -Hours 2) `
    -RepetitionDuration (New-TimeSpan -Days 30)

# Omit principal (uses current user)
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -Force

# Confirm registration
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Write-Host "Scheduled task registered successfully."
} else {
    Write-Host "Failed to register scheduled task."
}

# === Compiler Info
$Compiler = "Unknown"
if (Get-Command gcc -ErrorAction SilentlyContinue) {
    $Compiler = (& gcc --version | Select-Object -First 1)
} elseif (Get-Command clang -ErrorAction SilentlyContinue) {
    $Compiler = (& clang --version | Select-Object -First 1)
}

# === Version
$Version = if (Test-Path $VersionFile) { Get-Content $VersionFile -First 1 } else { "Unknown" }

# === Delete temp folder
Remove-Item -Path $TempFolder -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`nTemp folder deleted: $TempFolder"

# === Save Metadata (Dynamic WSL Detection)
$Meta = @{
    os_type        = "Windows"
    sub_os         = if ($WSLPaths.Count -gt 0) { "WSL" } else { "None" }
    compiler       = $Compiler
    env_var        = $IncludeVar
    lib_dir        = $TargetDir
    injected_paths = $Injected
    wsl_paths      = $WSLPaths
    version        = $Version
    install_time   = (Get-Date).ToString("o")
} | ConvertTo-Json -Depth 3

Set-Content -Path $MetaPath -Value $Meta


# === Cleanup Temp Folder
if (Test-Path $TempFolder) {
    try {
        Remove-Item -Path $TempFolder -Recurse -Force
        Write-Host "Temp folder deleted: $TempFolder"
    } catch {
        Write-Warning "Could not delete temp folder: $_"
    }
}

# === Final Log
Write-Host "`n Installation complete. Metadata saved to: $MetaPath"
Read-Host "Press Enter to exit"