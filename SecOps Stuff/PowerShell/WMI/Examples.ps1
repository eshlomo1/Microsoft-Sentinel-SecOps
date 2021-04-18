Get-WmiObject -class Win32_LogicalDisk -Filter "DriveType=3" 

Get-WmiObject -Namespace root\cimv2 -list | where name -like "*configuration*" | sort name 
 
Get-WmiObject -Namespace root\cimv2 -list | where name -like "*operating*" | sort name 

Get-WmiObject -class Win32_ComputerSystem | Select Manufacturer,Model,@{n='RAM';e={$PSItem.TotalPhysicalMemory}} 

Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'S%'" | select Name,State,StartName 
 
Get-WmiObject -class Win32_service -Filter "Name='WinRM'" | Invoke-WmiMethod -Name ChangeStartMode -Argument 'Automatic' 

Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | Format-Table -Property @{n='Drive Letter';e={$PSItem.DeviceID}},@{n='Free Space(GB)';e={$PSItem.FreeSpace / 1GB};formatstring='N0'},@{n='% Free Space';e={$PSItem.FreeSpace / $PSitem.Size * 100};formatstring='N0'}
