[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


# === CONFIG ===
$URL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/refs/heads/main/lib_Code/code.h"
$TargetDir = "$env:ProgramData\lib_Code"
$HeaderPath = Join-Path $TargetDir "code.h"
$IncludeVar = "INCLUDE"

Write-Host "Downloading code.h..."

# Create the target directory if it doesn't exist
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Download the header file
Invoke-WebRequest -Uri $URL -OutFile $HeaderPath -UseBasicParsing

# Add the directory to the global INCLUDE environment variable
$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)

if ($existing -notlike "*$TargetDir*") {
    if ($existing) {
        $new = "$existing;$TargetDir"
    } else {
        $new = "$TargetDir"
    }
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "INCLUDE path updated successfully."
} else {
    Write-Host "INCLUDE already contains the target directory."
}

Write-Host "code.h installed to: $HeaderPath"
Write-Host "#include <code.h> will now work globally."
