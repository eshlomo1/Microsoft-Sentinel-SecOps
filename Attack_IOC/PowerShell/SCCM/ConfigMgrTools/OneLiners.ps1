#Remove All Drivers within System Center Configuration Manager
Get-CMDriverPackage | % {Get-CMDriver -DriverPackageName $PSItem.Name} | Remove-CMDriver -Confirm:$false -Force -Verbose
