Write-Host "Uninstalling code.h from Windows..."
Write-Host ""

$TargetDir   = "$env:ProgramData\lib_Code"
$HeaderPath  = "$TargetDir\code.h"
$IncludeVar  = "INCLUDE"
$VersionDir  = Join-Path $TargetDir "version"

# Step 1: Remove from INCLUDE environment variable
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -and $existing -like "*$TargetDir*") {
    $new = $existing -replace [Regex]::Escape($TargetDir + ';'), ''
    $new = $new -replace [Regex]::Escape($TargetDir), ''
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Cleaned INCLUDE path"
}

# Step 2: Remove main file and version directory
if (Test-Path $HeaderPath) {
    Remove-Item -Force "$HeaderPath" -ErrorAction SilentlyContinue
    Write-Host "Deleted code.h"
}

if (Test-Path $VersionDir) {
    Remove-Item -Force "$VersionDir" -Recurse -ErrorAction SilentlyContinue
    Write-Host "Deleted version/ folder"
}

if (Test-Path $TargetDir) {
    Remove-Item -Force "$TargetDir" -Recurse -ErrorAction SilentlyContinue
    Write-Host "Deleted lib_Code directory"
}

# Step 3: Clean from MinGW paths
$MinGWPaths = @(
    "C:\MinGW",
    "C:\MinGW64",
    "C:\Program Files\mingw-w64",
    "C:\mingw64"
)

foreach ($path in $MinGWPaths) {
    $includeDir = Join-Path $path "include"
    $header = "$includeDir\code.h"
    if (Test-Path $header) {
        Remove-Item -Force "$header" -ErrorAction SilentlyContinue
        Write-Host "Removed from MinGW: $includeDir"
    }
}

# Step 4: Clean from MSVC include directories
$VCPaths = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Directory -Filter "include" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*VC\Tools\MSVC\*\include" }

foreach ($vc in $VCPaths) {
    $header = "$($vc.FullName)\code.h"
    if (Test-Path $header) {
        Remove-Item -Force "$header" -ErrorAction SilentlyContinue
        Write-Host "Removed from MSVC: $($vc.FullName)"
    }
}

Write-Host ""
Write-Host "Uninstallation complete."
