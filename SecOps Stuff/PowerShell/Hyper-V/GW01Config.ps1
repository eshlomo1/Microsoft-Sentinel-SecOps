#Rename Computer & Restart
Rename-Computer GW01; Restart-Computer

#Find External DHCP enabled interface
$External = (Get-NetIPAddress -AddressFamily IPv4).Where{$_.PrefixOrigin -eq 'Dhcp'}
#Rename DHCP adpter to External
Rename-NetAdapter -Name $External.InterfaceAlias -NewName 'External'
#Find Internal adpater
$Internal = (Get-NetIPAddress -AddressFamily IPv4).Where{$_.PrefixOrigin -ne 'Dhcp' -and $_.InterfaceAlias -notmatch 'Loopback'}
Rename-NetAdapter -Name $Internal.InterfaceAlias -NewName 'Internal'
#Set Internal Static Address
Get-NetAdapter -Name Internal | New-NetIPAddress -IPAddress 192.168.2.1 -AddressFamily IPv4 -PrefixLength 24
#Install Routing Feature
Install-WindowsFeature Routing
#Configure Nat & Routing
Install-RemoteAccess -VpnType Vpn
 
$ExternalInterface="External"
$InternalInterface="Internal"
 
cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface $ExternalInterface"
cmd.exe /c "netsh routing ip nat set interface $ExternalInterface mode=full"
cmd.exe /c "netsh routing ip nat add interface $InternalInterface"