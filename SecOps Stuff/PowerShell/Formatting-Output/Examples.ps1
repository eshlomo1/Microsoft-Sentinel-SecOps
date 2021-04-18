Get-process | ft ID,VM -autosize 
 
#Grabs only one result  
Get-aduser -filter * -properties * -resultsetsize 1  
 
Get-Process | format-table -Property Name,ID,@{n='VM(MB)';e={$PSItem.VM / 1MB};formatstring='N2' 
;align='right'} -autosize 
 
Get-Process | Format-Table -Property Name,ID,@{n='VM(MB)';e={$PSItem.VM / 1MB};formatString='N2'},@{n='PM(MB)';e={$PSItem.PM / 1MB};formatString='N2'} -AutoSize | Out-File Procs.txt 

Get-process | sort baseproperity | ft -groupby basepriority

Get-NetRoute | Format-Table -Property AddressFamily,RouteMetric,TypeOfRoute, @{n='DestinationPrefix';e={$PSItem.DestinationPrefix};align='right'} -AutoSize 

Get-ChildItem -Path C:\Windows\*.exe | Sort-Object -Property Length -Descending | Format-Table -Property Name,@{n='Size(KB)';e={$PSItem.Length / 1KB}; formatstring='N2'} -AutoSize 

Get-Eventlog -LogName Security -Newest 20 | Select-Object -Property *,@{n='TimeDifference';e={$PSItem.TimeWritten - $PSitem.TimeGenerated}} | sort-object -property TimeDifference -descending | Format-table -property EventID,TimeDifference -autosize
