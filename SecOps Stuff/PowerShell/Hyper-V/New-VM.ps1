$Name = 'Hyper-V'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'E:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '2'
$ISO_Path = 'D:\ISOs\Windows Server 2016\WindowsServer2016TP5.ISO'

New-VM -Name $Name -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 4096MB -Verbose

Add-VMDvdDrive -VMName $Name -Path $ISO_Path -Verbose

set-vm -ProcessorCount 2 -VMName $Name -Verbose

$MyDVD = Get-VMDvdDrive $Name
$MyHD = Get-VMHardDiskDrive $Name
$MyNIC = Get-VMNetworkAdapter $Name

Set-VMFirmware $Name -BootOrder $MyDVD,$MyHD,$MyNIC
Set-VMMemory $Name -DynamicMemoryEnabled $false

break