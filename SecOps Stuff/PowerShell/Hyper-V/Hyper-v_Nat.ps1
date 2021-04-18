New-VMSwitch -Name "NATSwitch" -SwitchType NAT -NATSubnetAddress "172.91.92.0/24"
New-NetNat -Name VMSwitchNat -InternalIPInterfaceAddressPrefix "172.91.92.0/24"

Invoke-Command -VMName Win10 -ScriptBlock {New-NetIPAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -IPAddress '172.91.92.2' -PrefixLength 24 -DefaultGateway '172.91.92.1'}