[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


$TargetDir = "$env:ProgramData\lib_Code"
$HeaderPath = "$TargetDir\code.h"
$IncludeVar = "INCLUDE"

Write-Host "Uninstalling code.h from Windows..."

if (Test-Path $HeaderPath) {
    Remove-Item $HeaderPath -Force
    Write-Host "Removed code.h"
}

if (Test-Path $TargetDir) {
    Remove-Item $TargetDir -Recurse -Force
    Write-Host "Removed $TargetDir"
}

$existing = [Environment]::GetEnvironmentVariable($IncludeVar, [System.EnvironmentVariableTarget]::Machine)
if ($existing -and $existing.Contains($TargetDir)) {
    $new = ($existing -split ';') -ne $TargetDir -join ';'
    [Environment]::SetEnvironmentVariable($IncludeVar, $new, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Removed $TargetDir from INCLUDE path"
}

Write-Host "Uninstallation complete (Windows)"