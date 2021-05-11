Function Enter-CMSession {
<#
.SYNOPSIS

Imports the System Center Configuration Manager Module & Connects to Configuration Manager PS-Drive.

.DESCRIPTION

Imports the System Center Configuration Manager module and then changes location to the sitecode PS drive specified.

.PARAMETER SiteCode

Specifies the SiteCode of the SCCM server to connect to.

.EXAMPLE

Enter-CMSession -SiteCode PS1

#>
[CmdletBinding()]

param (
  [Parameter(Mandatory=$True,HelpMessage="Enter the SiteCode of the SCCM Server")]
  [String]$SiteCode
  )

    Try
    {
    Write-Verbose "Connecting to $computername"
    Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -ErrorAction Stop
    Set-Location "$($SiteCode):"
    }
    Catch [System.IO.FileNotFoundException]
    {
        "SCCM Admin Console not installed"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }
    Finally
    {
        Write-Verbose "Finished running command"
        "This Script attempted to import the SCCM module"
    }
}
