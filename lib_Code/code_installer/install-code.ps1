# install-code.ps1 — Installs code.h from lib_Code/ or downloads if needed

$DownloadURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
$LocalFolder = Join-Path $PSScriptRoot "lib_Code"
$HeaderPath = Join-Path $LocalFolder "code.h"
$VersionPath = Join-Path $LocalFolder "version\code.version"
$MetaPath = Join-Path $LocalFolder "code.meta"
$TargetDir = "$env:ProgramData\lib_Code"
$IncludeVar = "INCLUDE"

# --- Ensure lib_Code/ exists and code.h present ---
if (!(Test-Path $HeaderPath)) {
    if (!(Test-Path $LocalFolder)) {
        New-Item -ItemType Directory -Path $LocalFolder | Out-Null
    }
    Write-Host "Downloading code.h..."
    Invoke-WebRequest -Uri $DownloadURL -OutFile $HeaderPath -UseBasicParsing
}

# Copy lib_Code to ProgramData
Copy-Item -Path $LocalFolder -Destination $TargetDir -Recurse -Force
Write-Host "Installed to $TargetDir"

# === Update INCLUDE env var
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -notlike "*$TargetDir*") {
    $new = if ($existing) { "$existing;$TargetDir" } else { "$TargetDir" }
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Updated INCLUDE environment variable"
}

# === Inject into known Windows compilers
$Injected = @()
$MinGWPaths = @("C:\MinGW", "C:\MinGW64", "C:\Program Files\mingw-w64", "C:\mingw64")
foreach ($path in $MinGWPaths) {
    $includeDir = Join-Path $path "include"
    if (Test-Path $includeDir) {
        Copy-Item -Path $HeaderPath -Destination "$includeDir\code.h" -Force
        $Injected += $includeDir
        Write-Host "Injected into MinGW at $includeDir"
    }
}

$VCPaths = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Directory -Filter "include" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*VC\Tools\MSVC\*\include" }
foreach ($vc in $VCPaths) {
    Copy-Item -Path $HeaderPath -Destination "$($vc.FullName)\code.h" -Force
    $Injected += $vc.FullName
    Write-Host "Injected into MSVC at $($vc.FullName)"
}

# === Deploy to WSL
$WSLPaths = @()
if (Test-Path "$env:windir\System32\wsl.exe") {
    Write-Host "Deploying to WSL..."

    try {
        # === Deploy code.h
        $HeaderPathFull = (Resolve-Path $HeaderPath).Path
        $headerWSL = wsl wslpath -a -u "`"$HeaderPathFull`"" | ForEach-Object { $_.Trim() }

        $cpSuccess = $true
        try {
            wsl bash -c "sudo cp '$headerWSL' '/usr/local/include/code.h'"
            Write-Host "WSL cp: success"
        } catch {
            $cpSuccess = $false
        }

        if (-not $cpSuccess) {
            try {
                Get-Content -Raw -Encoding Byte "$HeaderPathFull" | wsl bash -c "cat | sudo tee /usr/local/include/code.h >/dev/null"
                Write-Host "Fallback (cat) success: code.h deployed to WSL"
            } catch { }
        }

        $WSLPaths += "/usr/local/include/code.h"

        # === Ensure unzip is available in WSL
        Write-Host "Checking for unzip in WSL..."
        $hasUnzip = wsl which unzip 2>$null
        if (-not $hasUnzip) {
            try {
                wsl bash -c "command -v unzip >/dev/null 2>&1 || (sudo apt-get update -qq >/dev/null && sudo apt-get install -y unzip >/dev/null)"
                Write-Host "unzip installed (or already present)"
            } catch {
                Write-Host "WARNING: Failed to install unzip. version/ folder copy may fail"
            }
        }

        # === Zip and extract version/ into WSL
        $VersionFolder = Join-Path $PSScriptRoot "version"
        if (Test-Path $VersionFolder) {
            $TempZip = Join-Path $env:TEMP "version_files.zip"
            if (Test-Path $TempZip) { Remove-Item $TempZip -Force }

            Compress-Archive -Path "$VersionFolder\*" -DestinationPath $TempZip -Force

            $ZipWSL = wsl wslpath -a -u "`"$TempZip`"" | ForEach-Object { $_.Trim() }
            wsl bash -c "sudo mkdir -p /usr/local/lib_Code/version && sudo unzip -o '$ZipWSL' -d /usr/local/lib_Code/version >/dev/null"
            Write-Host "Copied version/ folder to WSL /usr/local/lib_Code/version"

            # Log WSL paths
            foreach ($f in Get-ChildItem $VersionFolder -File) {
                $WSLPaths += "/usr/local/lib_Code/version/$($f.Name)"
            }
        }
    } catch {
        Write-Host "Failed to deploy to WSL: $_"
    }
}

# === Compiler Info
$Compiler = "Unknown"
if (Get-Command gcc -ErrorAction SilentlyContinue) {
    $Compiler = (& gcc --version | Select-Object -First 1)
} elseif (Get-Command clang -ErrorAction SilentlyContinue) {
    $Compiler = (& clang --version | Select-Object -First 1)
}

# === Version
$Version = if (Test-Path $VersionPath) { Get-Content $VersionPath -First 1 } else { "Unknown" }

# === Save Metadata
$Meta = @{
    os_type        = "Windows"
    sub_os         = "WSL"
    compiler       = $Compiler
    env_var        = $IncludeVar
    lib_dir        = $TargetDir
    header_path    = Join-Path $TargetDir "code.h"
    injected_paths = $Injected
    wsl_paths      = $WSLPaths
    version        = $Version
} | ConvertTo-Json -Depth 3

# === Auto-inject updater
$InjectScript = Join-Path $PSScriptRoot "version\inject-updater.ps1"
if (Test-Path $InjectScript) {
    Write-Host "Injecting auto-updater task..."
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "`"$InjectScript`""
}

# === Inject WSL updater hook (if WSL is installed)
if (Test-Path "$env:windir\System32\wsl.exe") {
    $InjectScriptWSL = Join-Path $PSScriptRoot "version\inject-updater.sh"
    if (Test-Path $InjectScriptWSL) {
        $InjectScriptWSLWin = Resolve-Path $InjectScriptWSL
        $InjectScriptWSLUnix = wsl wslpath -a -u "`"$InjectScriptWSLWin`""
        Write-Host "Injecting auto-updater into WSL..."
        wsl bash $InjectScriptWSLUnix
    } else {
        Write-Host "inject-updater.sh not found at $InjectScriptWSL"
    }
}

Set-Content -Path $MetaPath -Value $Meta
Write-Host "`n Installation complete. Metadata saved to: $MetaPath"
Read-Host "Press Enter to exit"
