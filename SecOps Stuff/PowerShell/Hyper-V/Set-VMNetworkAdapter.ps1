#Source http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/17/change-virtual-machine-network-configuration-with-powershell.aspx
GET-VM | GET-VMNetworkAdapter | Connect-VMNetworkAdapter –Switchname ‘New-cool-Hyper-V-Lan’
