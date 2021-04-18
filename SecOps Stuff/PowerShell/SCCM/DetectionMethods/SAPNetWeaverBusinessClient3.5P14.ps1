$osarch = (gwmi win32_operatingsystem).osarchitecture
if ($osarch -eq "64-bit") {
$NWBCPatch = (Get-ItemProperty -Path 'C:\Program Files (x86)\SAP\NWBC35\NWBC.exe' -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
} else {
$NWBCPatch = (Get-ItemProperty -Path 'C:\Program Files\SAP\NWBC35\NWBC.exe' -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
}

if($NWBCPatch -ne $null) { Write-Host "Installed" }
