Get-NetAdapter | Select Name,MacAddress #Select NetAdpter with internet access
Get-NetAdapter | Select Name,InterfaceDescription

$NetAdapterName = (Get-NetAdapter).Name
New-VMSwitch -NetAdapterName $NetAdapterName[0] -Name 'External' #Create External internet providing Hyper-v adapter
New-VMSwitch -SwitchType Internal -Name 'Internal'

$Servers = 'ZDC01','HDC01'

Foreach ($Server in $Servers){
    $Name = $Server
    $SwitchName = 'Internal'
    $HardDiskSize = 32GB
    $HDPath = 'C:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
    $Generation = '2'
    $ISO_Path = 'C:\Hyper-V\ISO\WindowsServer2016TechnicalPreview4.ISO'

    New-VM -Name $Name -SwitchName $SwitchName `
    -NewVHDSizeBytes $HardDiskSize `
    -NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

    Add-VMDvdDrive -VMName $Name -Path $ISO_Path

    $MyDVD = Get-VMDvdDrive $Name
    $MyHD = Get-VMHardDiskDrive $Name
    $MyNIC = Get-VMNetworkAdapter $Name

    Set-VMFirmware $Name -BootOrder $MyDVD,$MyHD,$MyNIC
    Set-VMMemory $Name -DynamicMemoryEnabled $false

    If ($Server -eq 'GW01'){Add-VMNetworkAdapter -VMName $Server -SwitchName External}
    Start-VM -vm $Server
}

$Name = 'Win7'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'C:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '1'
$ISO_Path = 'C:\Hyper-V\ISO\Windows7ProfessionalSP1x64t.iso'

New-VM -Name $Name -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

Add-VMDvdDrive -VMName $Name -Path $ISO_Path
