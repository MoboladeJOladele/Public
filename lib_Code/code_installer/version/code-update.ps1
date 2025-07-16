# === CONFIG ===
$libDir     = "$env:ProgramData\lib_Code"
$headerPath = Join-Path $libDir "code.h"
$versionDir = Join-Path $libDir "version"
$versionPath = Join-Path $versionDir "code.version"

$remoteVersionURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code_installer/version/code.version"
$remoteHeaderURL  = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"

# Ensure folder exists
if (-not (Test-Path $versionDir)) {
    New-Item -ItemType Directory -Path $versionDir -Force | Out-Null
}

# Fetch remote version
try {
    $remoteVersion = Invoke-RestMethod -Uri $remoteVersionURL -UseBasicParsing
} catch {
    exit 0
}

# Read local version
$localVersion = if (Test-Path $versionPath) {
    Get-Content $versionPath -Raw
} else {
    "none"
}

# Compare and update if needed
if ($remoteVersion -ne $localVersion) {
    try {
        Invoke-WebRequest -Uri $remoteHeaderURL -OutFile $headerPath -UseBasicParsing
        Set-Content -Path $versionPath -Value $remoteVersion
    } catch {
        exit 0
    }
}
