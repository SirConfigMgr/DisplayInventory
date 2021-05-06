
## Files
$InstallPath = "C:\ProgramData\SirConfigMgr\MonitorInventory"
If (!(Test-Path $InstallPath)) {New-Item -Path $InstallPath -ItemType directory -Force}
Copy $PSScriptRoot\*.* $InstallPath -Force

## ARP
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MonitorInventory"
New-Item -Path $RegPath -Force
New-ItemProperty -Path $RegPath -Name DisplayIcon -Value "C:\ProgramData\SirConfigMgr\MonitorInventory\icon.ico" -PropertyType String -Force
New-ItemProperty -Path $RegPath -Name DisplayName -Value "Monitor Inventory" -PropertyType String -Force
New-ItemProperty -Path $RegPath -Name DisplayVersion -Value "2.0" -PropertyType String -Force
New-ItemProperty -Path $RegPath -Name Publisher -Value "SirConfigMgr" -PropertyType String -Force
New-ItemProperty -Path $RegPath -Name UninstallString -Value "powershell.exe -executionpolicy bypass -windowstyle hidden -file C:\ProgramData\SirConfigMgr\MonitorInventory\Uninstall.ps1" -PropertyType String -Force

## Scheduled Task
$Action = New-ScheduledTaskAction -Execute '"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"' -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass -File $InstallPath\MonitorInventory.ps1"
$Principal = New-ScheduledTaskPrincipal -GroupId "NT Authority\System" -RunLevel Highest
$Trigger =  New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Monday -At 10am

$OldTask = Get-ScheduledTask -TaskName "MonitorInventory" -ErrorAction SilentlyContinue
If ($OldTask) {
    Unregister-ScheduledTask -TaskName "MonitorInventory" -Confirm:$false
    }
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "MonitorInventory" -Principal $Principal
Start-ScheduledTask -TaskName "MonitorInventory"