##
## Test services
##
$session = New-PSSession -ComputerName 'server02', 'server03'

'DFSR', 'NtFrs', 'Kdc', 'W32Time', 'ADWS', 'DNS', 'EventLog', 'gpsvc', 'Netlogon', 'NTDS', 'wuauserv' |
foreach -BEGIN {
 $sb = {
  param($service)
  Get-Service -Name $service
 }
} -PROCESS {
Invoke-Command -Session $session -ScriptBlock $sb -ArgumentList $psitem
} 

$session | Remove-PSSession