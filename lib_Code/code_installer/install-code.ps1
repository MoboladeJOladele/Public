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
        $HeaderPathFull = (Resolve-Path $HeaderPath).Path
        $headerWSL = wsl wslpath -a -u "`"$HeaderPathFull`""
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
                Get-Content -Raw -Encoding Byte "$HeaderPathFull" | wsl bash -c "cat | sudo tee /usr/local/include/code.h >/dev/null"
                Write-Host "Fallback (cat) success: code.h deployed to WSL"
            } catch { }
        }

        $WSLPaths += "/usr/local/include/code.h"
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

Set-Content -Path $MetaPath -Value $Meta
Write-Host "`n Installation complete. Metadata saved to: $MetaPath"
Read-Host "Press Enter to exit"
