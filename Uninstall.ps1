
## Files
$InstallPath = "C:\ProgramData\SirConfigMgr\MonitorInventory"
If (Test-Path $InstallPath) {Remove-Item -Path $InstallPath -Recurse -Force}

## ARP
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MonitorInventory"
If (Test-Path $RegPath) {Remove-Item -Path $RegPath -Recurse -Force}

## Scheduled Task
$Task = Get-ScheduledTask -TaskName "MonitorInventory" -ErrorAction SilentlyContinue
If ($Task) {
    Unregister-ScheduledTask -TaskName "MonitorInventory" -Confirm:$false
    }

## WMI Class
$Class = Get-WmiObject Win32_MonitorDetails -ErrorAction SilentlyContinue
If ($Class) {Remove-WmiObject -Class Win32_MonitorDetails}