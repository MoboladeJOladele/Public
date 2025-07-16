# === CONFIG ===
$URL         = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
$VersionURL  = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
$HookURL     = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/hook-updater.sh"
$TargetDir   = "$env:ProgramData\lib_Code"
$HeaderPath  = Join-Path $TargetDir "code.h"
$MetaPath    = Join-Path $TargetDir "code.meta"
$IncludeVar  = "INCLUDE"

"INSTALL STARTED" | Out-File "$env:TEMP\code-install-log.txt" -Append
Write-Host "Downloading code.h..."

# === Prepare directory and download header
If (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}
Invoke-WebRequest -Uri $URL -OutFile $HeaderPath -UseBasicParsing

# === Add to INCLUDE path
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -notlike "*$TargetDir*") {
    $new = if ($existing) { "$existing;$TargetDir" } else { "$TargetDir" }
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Updated INCLUDE path"
}

# === Inject into MinGW and MSVC
$MinGWPaths = @("C:\MinGW", "C:\MinGW64", "C:\Program Files\mingw-w64", "C:\mingw64")
$Injected = @()
foreach ($path in $MinGWPaths) {
    $includeDir = Join-Path $path "include"
    if (Test-Path $includeDir) {
        Copy-Item -Path $HeaderPath -Destination "$includeDir\code.h" -Force -ErrorAction SilentlyContinue
        $Injected += $includeDir
        Write-Host "Injected into MinGW at $includeDir"
    }
}

$VCPaths = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Directory -Filter "include" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*VC\Tools\MSVC\*\include" }
foreach ($vc in $VCPaths) {
    Copy-Item -Path $HeaderPath -Destination "$($vc.FullName)\code.h" -Force -ErrorAction SilentlyContinue
    $Injected += $vc.FullName
    Write-Host "Injected into MSVC at $($vc.FullName)"
}

# === WSL Detection
$HasWSL = Test-Path "$env:windir\System32\wsl.exe"
$SubOS = if ($HasWSL) { "WSL" } else { "None" }
$WSLPaths = @()

if ($HasWSL) {
    $wslHeader      = "/usr/local/include/lib_Code/code.h"
    $wslMeta        = "/usr/local/include/lib_Code/code.meta"
    $wslVersionDir  = "/usr/local/include/lib_Code/version"
    $hookScriptPath = "$wslVersionDir/hook-updater.sh"

    wsl sudo mkdir -p "/usr/local/include/lib_Code/version"
    wsl sudo curl -fsSL "$URL" -o "$wslHeader"
    wsl sudo ln -sf "$wslHeader" "/usr/local/include/code.h"
    wsl sudo curl -fsSL "$HookURL" -o "$hookScriptPath"
    wsl sudo chmod +x "$hookScriptPath"

    # Generate metadata
    $wslCompiler = (wsl gcc --version | Out-String).Split("`n")[0]
    $wslMetaContent = @"
{
  "os_type": "Linux",
  "sub_os": "WSL",
  "compiler": "$wslCompiler",
  "env_var": null,
  "lib_dir": "/usr/local/include/lib_Code",
  "header_path": "$wslHeader",
  "injected_paths": ["/usr/local/include"],
  "version": "unknown"
}
"@
    $tempMeta = "$env:TEMP\wsl-code.meta"
    $wslMetaContent | Out-File -Encoding utf8 $tempMeta
    wsl sudo cp "$(wsl wslpath -a -u "$tempMeta")" "$wslMeta"
    Write-Host "WSL metadata written to: $wslMeta"

    # Add NOPASSWD rule for hook-updater.sh
    $sudoersLine = 'ALL ALL=(ALL) NOPASSWD: /usr/local/include/lib_Code/version/hook-updater.sh'
    $escaped = $sudoersLine -replace '"', '\"'
    wsl bash -c "echo '$escaped' | sudo tee /etc/sudoers.d/code_h >/dev/null"
    Write-Host "Sudoers exception added for hook-updater.sh"

    $WSLPaths += $wslHeader
}

# === Fetch Version
try {
    $Version = Invoke-RestMethod -Uri $VersionURL -UseBasicParsing
} catch {
    $Version = "Unknown"
}

# === Detect Compiler
if (Get-Command gcc -ErrorAction SilentlyContinue) {
    $Compiler = (& gcc --version)[0]
} elseif (Get-Command clang -ErrorAction SilentlyContinue) {
    $Compiler = (& clang --version)[0]
} else {
    $Compiler = "Unknown"
}

# === Write Windows Metadata
$Meta = @{
    os_type        = "Windows"
    sub_os         = $SubOS
    compiler       = $Compiler
    env_var        = $IncludeVar
    lib_dir        = $TargetDir
    header_path    = $HeaderPath
    injected_paths = $Injected
    wsl_paths      = $WSLPaths
    version        = $Version
} | ConvertTo-Json -Depth 3
Set-Content -Path $MetaPath -Value $Meta

Write-Host "Installation complete. Metadata saved to: $MetaPath"
"INSTALL COMPLETED" | Out-File "$env:TEMP\code-install-log.txt" -Append
