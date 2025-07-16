# === CONFIG ===
$URL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/refs/heads/main/lib_Code/code.h"
$TargetDir = "$env:ProgramData\lib_Code"
$HeaderPath = Join-Path $TargetDir "code.h"
$IncludeVar = "INCLUDE"

Write-Host "Downloading code.h..."

If (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Invoke-WebRequest -Uri $URL -OutFile $HeaderPath -UseBasicParsing

# === Set Environment INCLUDE path
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -notlike "*$TargetDir*") {
    $new = if ($existing) { "$existing;$TargetDir" } else { "$TargetDir" }
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Updated INCLUDE path"
}

# === Inject into known compilers

# --- MinGW
$MinGWPaths = @(
    "C:\MinGW",
    "C:\MinGW64",
    "C:\Program Files\mingw-w64",
    "C:\mingw64"
)

foreach ($path in $MinGWPaths) {
    $includeDir = Join-Path $path "include"
    if (Test-Path $includeDir) {
        Copy-Item -Path $HeaderPath -Destination "$includeDir\code.h" -Force -ErrorAction SilentlyContinue
        Write-Host "Injected into MinGW at $includeDir"
    }
}

# --- MSVC (via VCTools path detection)
$VCPaths = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Directory -Filter "include" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*VC\Tools\MSVC\*\include" }

foreach ($vc in $VCPaths) {
    Copy-Item -Path $HeaderPath -Destination "$($vc.FullName)\code.h" -Force -ErrorAction SilentlyContinue
    Write-Host "Injected into MSVC at $($vc.FullName)"
}

Write-Host "code.h installed to: $HeaderPath"
Write-Host "#include <code.h> will now work globally"
