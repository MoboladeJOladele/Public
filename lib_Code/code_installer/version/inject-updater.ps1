# === CONFIG ===
$TaskName = "CodeHeaderAutoUpdate"
$ScriptPath = Join-Path $PSScriptRoot "code-update.ps1"

# Escape any potential spaces
$Action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Remove existing task if it exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Register new scheduled task
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$ActionObj = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $ActionObj -Principal $Principal

Write-Host "Scheduled Task '$TaskName' created successfully to run at startup."
