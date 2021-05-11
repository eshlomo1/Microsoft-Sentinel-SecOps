# ---------------------------------------------------
# Version: 3.0
# Author: Joshua Duffney
# Date: 07/15/2014
# Updated: 8/9/2014
# Description: Using PowerShell to check for a list of devices in SCCM and AD then returning the results in a table format.
# Comments: Populate computers.txt with a list of computer names then run the script.
# References: @thesurlyadm1n, @adbertram
# ---------------------------------------------------

Function DeviceCheck {
    Param(
        [string]$SiteServerName = 'ServerName',
        [string]$SiteCode = 'SiteCode',
        [string]$ComputerList
        )

## Connect to SCCM
    $ErrorActionPreference = "stop"

    if (!(Test-Path "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1")) {
        Write-Error 'Configuration Manager module not found. Is the admin console installed?'
        } elseif (!(Get-Module 'ConfigurationManager')) {
            Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
        }
        Set-Location "$($SiteCode):"

## Looking for device in SCCM

foreach ($computer in (Get-Content $ComputerList)) 
{
$value = Get-CMDevice -Name $computer
if ($value -eq $null){$Results = "NO"}
else{$Results = "Yes"}

## Looking for device in Active Directory

try {
    Get-ADComputer $computer -ErrorAction Stop | Out-Null
    $computerResults = $true
}
Catch {
    $computerResults = $false

}

[PSCustomObject]@{
        Name = $computer
        SCCM = $Results
        AD = $computerResults
        }

}

}

DeviceCheck -SiteServerName ServerName -SiteCode SiteCode -ComputerList "D:\Scripts\computers.txt"
