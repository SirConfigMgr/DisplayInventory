$Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
$MonitorInfo = @()
$ManufacturerList = @{ 
    "AAC" =	"AcerView";
    "ACR" = "Acer";
    "AOC" = "AOC";
    "AIC" = "AG Neovo";
    "APP" = "Apple Computer";
    "AST" = "AST Research";
    "AUO" = "Asus";
    "BNQ" = "BenQ";
    "CMO" = "Acer";
    "CPL" = "Compal";
    "CPQ" = "Compaq";
    "CPT" = "Chunghwa Pciture Tubes, Ltd.";
    "CTX" = "CTX";
    "DEC" = "DEC";
    "DEL" = "Dell";
    "DPC" = "Delta";
    "DWE" = "Daewoo";
    "EIZ" = "EIZO";
    "ELS" = "ELSA";
    "ENC" = "EIZO";
    "EPI" = "Envision";
    "FCM" = "Funai";
    "FUJ" = "Fujitsu";
    "FUS" = "Fujitsu-Siemens";
    "GSM" = "LG Electronics";
    "GWY" = "Gateway 2000";
    "HEI" = "Hyundai";
    "HIT" = "Hyundai";
    "HSL" = "Hansol";
    "HTC" = "Hitachi/Nissei";
    "HWP" = "Hewlett-Packard";
    "IBM" = "IBM";
    "ICL" = "Fujitsu ICL";
    "IVM" = "Iiyama";
    "KDS" = "Korea Data Systems";
    "LEN" = "Lenovo";
    "LGD" = "Asus";
    "LPL" = "Fujitsu";
    "MAX" = "Belinea"; 
    "MEI" = "Panasonic";
    "MEL" = "Mitsubishi Electronics";
    "MS_" = "Panasonic";
    "NAN" = "Nanao";
    "NEC" = "NEC";
    "NOK" = "Nokia Data";
    "NVD" = "Fujitsu";
    "OPT" = "Optoma";
    "PHL" = "Philips";
    "REL" = "Relisys";
    "SAN" = "Samsung";
    "SAM" = "Samsung";
    "SBI" = "Smarttech";
    "SGI" = "SGI";
    "SNY" = "Sony";
    "SRC" = "Shamrock";
    "SUN" = "Sun Microsystems";
    "SEC" = "Hewlett-Packard";
    "TAT" = "Tatung";
    "TOS" = "Toshiba";
    "TSB" = "Toshiba";
    "VSC" = "ViewSonic";
    "ZCM" = "Zenith";
    "UNK" = "Unknown";
    "_YV" = "Fujitsu";
}

ForEach ($Monitor in $Monitors)
{
    $IN = $Monitor.InstanceName
    $IN = $IN.Substring(0,$IN.Length -2)
    $MI = @{}
    $MI.MonitorID = (($Monitor.InstanceName).Split("\"))[1]
    $MI.PnpID = (((Get-WMIObject Win32_PnPEntity -Filter "Service='monitor'" | Where-Object {$_.PNPDeviceID -like "*$($MI.MonitorID)*"}).PNPDeviceID).Split("\"))[2]
    $MI.Name = (Get-WMIObject Win32_PnPEntity -Filter "Service='monitor'" | Where-Object {$_.PNPDeviceID -eq $IN}).Name
	$MI.Manufacturer = ($Monitor.ManufacturerName -gt 0 | ForEach{[char]$_}) -join ""
	$MI.Model = ($Monitor.UserFriendlyName -gt 0 | ForEach{[char]$_}) -join ""
	$MI.SerialNumber = ($Monitor.SerialNumberID -gt 0 | ForEach{[char]$_}) -join ""
    $MI.ManufacturingYear = $Monitor.YearOfManufacture
    $MI.ManufacturingWeek = $Monitor.WeekOfManufacture
    $Connection = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams | Where-Object {$_.InstanceName -eq $Monitor.InstanceName}).VideoOutputTechnology
    If ($Connection -eq "4") {$MI.Connection = "DVI"}
        ElseIf ($Connection -eq "5") {$MI.Connection = "HDMI"}
        ElseIf ($Connection -eq "10") {$MI.Connection = "DP"}
        Else {$MI.Connection = "Unknown"}
        If ( $ManufacturerList[$MI.Manufacturer] ) {
            $MI.Manufacturer = $ManufacturerList[$MI.Manufacturer]
        }
    $MonitorInfo += $MI
}

$Class = Get-WmiObject Win32_MonitorDetails -ErrorAction SilentlyContinue
If ($Class) {Remove-WmiObject -Class Win32_MonitorDetails}

$WMIClass = New-Object System.Management.ManagementClass("root\cimv2", [String]::Empty, $null);
$WMIClass["__CLASS"] = "Win32_MonitorDetails";
$WMIClass.Qualifiers.Add("Static", $true)
$WMIClass.Properties.Add("PnPID", [System.Management.CimType]::String, $false)
$WMIClass.Properties["PnPID"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("ManufacturingYear", [System.Management.CimType]::UInt32, $false)
$WMIClass.Properties["ManufacturingYear"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("ManufacturingWeek", [System.Management.CimType]::UInt32, $false)
$WMIClass.Properties["ManufacturingWeek"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("Manufacturer", [System.Management.CimType]::String, $false)
$WMIClass.Properties["Manufacturer"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("Model", [System.Management.CimType]::String, $false)
$WMIClass.Properties["Model"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
$WMIClass.Properties["Name"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("SerialNumber", [System.Management.CimType]::String, $false)
$WMIClass.Properties["SerialNumber"].Qualifiers.Add("key", $true)
$WMIClass.Properties["SerialNumber"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("MonitorID", [System.Management.CimType]::String, $false)
$WMIClass.Properties["MonitorID"].Qualifiers.Add("read", $true)
$WMIClass.Properties.Add("Connection", [System.Management.CimType]::String, $false)
$WMIClass.Properties["Connection"].Qualifiers.Add("read", $true)
$WMIClass.Put()

ForEach ($MInfo in $MonitorInfo) {
    [void](Set-WmiInstance -Path \\.\root\cimv2:Win32_MonitorDetails -Arguments @{Connection=$MInfo.Connection; MonitorID=$MInfo.MonitorID; PnPID= $MInfo.PnPID; ManufacturingYear=$MInfo.ManufacturingYear; ManufacturingWeek=$MInfo.ManufacturingWeek; Manufacturer=$MInfo.Manufacturer; Model=$MInfo.Model; Name=$MInfo.Name; SerialNumber=$MInfo.SerialNumber})
}