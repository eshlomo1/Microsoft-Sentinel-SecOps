#Find InterfaceAlias,Name,and InterfaceIndex
Get-NetAdapter | select Name,InterfaceAlias,InterfaceIndex
#Set Default Gateway & IP Address
New-NetIPAddress –InterfaceAlias "Ethernet" –PrefixLength 24 –DefaultGateway 192.168.16.1 -IPAddress 192.168.1.105
#Set DNS
Set-DNSClientServerAddress –InterfaceAlias "Ethernet" –ServerAddress 192.168.16.10, 192.168.16.11 

#Reference
#http://www.falconitservices.com/support/KB/Lists/Posts/Post.aspx?ID=100
