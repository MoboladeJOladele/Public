# === CONFIG ===
$URL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/version/code.version"
$RemoteHeaderURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/lib_Code/code.h"
$TargetDir = "$env:ProgramData\lib_Code"
$HeaderPath = "$TargetDir\code.h"
$LocalVersionFile = "$TargetDir\code.version"

# === Ensure directory exists
if (!(Test-Path $TargetDir)) {
    exit
}

# === Fetch remote version
try {
    $remoteVersion = Invoke-RestMethod -Uri $URL -UseBasicParsing
} catch {
    exit
}

# === Fetch local version
if (Test-Path $LocalVersionFile) {
    $localVersion = Get-Content $LocalVersionFile -Raw
} else {
    $localVersion = "0.0.0"
}

# === Compare versions
if ($remoteVersion -ne $localVersion) {
    Invoke-WebRequest -Uri $RemoteHeaderURL -OutFile $HeaderPath -UseBasicParsing
    Set-Content -Path $LocalVersionFile -Value $remoteVersion
}
