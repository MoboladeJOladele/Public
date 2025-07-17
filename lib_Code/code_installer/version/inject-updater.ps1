# === CONFIG ===
$TaskName = "CodeHeaderAutoUpdate"

# Dynamically get path to code-update.ps1
$ScriptPath = Join-Path $PSScriptRoot "code-update.ps1"

# Validate existence
if (-not (Test-Path $ScriptPath)) {
    Write-Host "ERROR: code-update.ps1 not found at $ScriptPath"
    exit 1
}

# Delete existing task if exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create new scheduled task
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Principal $Principal

Write-Host "Auto-update task '$TaskName' created successfully."
