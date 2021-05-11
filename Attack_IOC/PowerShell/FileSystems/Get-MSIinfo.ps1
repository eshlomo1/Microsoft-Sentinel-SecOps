<#
.SYNOPSIS

Gather MSI information

.DESCRIPTION

Invokes methods to query all msi files at a specific location.

.PARAMETER Path

Provide the location of the .MSI file.

.PARAMETER Property

Select one of the three properties to return from the .MSI file.
ProductCode,ProductVersion,ProductName

.Example

Get-MSIinfo -Path C:\MSI -Property ProductCode

.Link

http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/


#>

function Get-MSIinfo {

    param(
    [parameter(Mandatory=$true)]
    [IO.FileInfo]$Path,
    [parameter(Mandatory=$true)]
    [ValidateSet("ProductCode","ProductVersion","ProductName")]
    [string]$Property
    )
        try {
            $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
            $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase","InvokeMethod",$Null,$WindowsInstaller,@($Path.FullName,0))
            $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
            $View = $MSIDatabase.GetType().InvokeMember("OpenView","InvokeMethod",$null,$MSIDatabase,($Query))
            $null = $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
            $Record = $View.GetType().InvokeMember("Fetch","InvokeMethod",$null,$View,$null)
            $Value = $Record.GetType().InvokeMember("StringData","GetProperty",$null,$Record,1)
            return $Value
        }
        catch {
            Write-Output $_.Exception.Message
        }

}
