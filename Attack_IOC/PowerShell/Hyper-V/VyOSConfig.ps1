$Name = 'VyOS'
$SwitchName = 'Internal'
$HardDiskSize = 2GB
$HDPath = 'E:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '1'
$ISO_Path = 'D:\ISOs\vyos-1.1.6-amd64.iso'

New-VM -Name $Name -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 512MB

Add-VMDvdDrive -VMName $Name -Path $ISO_Path

Add-VMNetworkAdapter -VMName $Name -SwitchName External