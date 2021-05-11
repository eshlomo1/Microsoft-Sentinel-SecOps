#Create ZDC01 Primary DC
$Name = 'ZDC01'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'F:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '2'
$ISO_Path = 'D:\ISOs\10514.0.150808-1529.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO'

New-VM -Name $Name -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

Add-VMDvdDrive -VMName $Name -Path $ISO_Path


$MyDVD = Get-VMDvdDrive $Name
$MyHD = Get-VMHardDiskDrive $Name
$MyNIC = Get-VMNetworkAdapter $Name

Set-VMFirmware $Name -BootOrder $MyDVD,$MyHD,$MyNIC
Set-VMMemory $Name -DynamicMemoryEnabled $false
break

#Image Server

#Copy down all needed resources
Save-Module -Name 'xNetworking','xDHCPServer','xComputerManagement','xActiveDirectory','xPSDesiredStateConfiguration','xTimeZone' -Path 'C:\LabResources'
#Create .iso with imgburn

#mount .iso with dsc resources
$LabResourcePath = 'C:\Hyper-V\ISO\DSCResources.iso'
Set-VMDvdDrive -VMName $Name -Path $LabResourcePath

Invoke-Command -VMName $Name -ScriptBlock {Rename-Computer -NewName 'ZDC01';Restart-Computer -Force}
Invoke-Command -VMName $Name -ScriptBlock {Copy-Item -Path D:\* -Recurse -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Force}
Invoke-Command -VMName $name -ScriptBlock {C:\'Program Files\WindowsPowerShell\Modules\DSCLab.ps1'} -Verbose
Invoke-Command -VMName $Name -ScriptBlock {Get-DnsServerForwarder | Remove-DnsServerForwarder}

#Rename HDC01 and restart
$SecondDC = 'HDC01'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'F:\Hyper-V\Virtual Hard Disks'+'\'+$Name+'.vhdx'
$Generation = '2'
$ISO_Path = 'D:\ISOs\10514.0.150808-1529.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO'

New-VM -Name $SecondDC -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

Add-VMDvdDrive -VMName $Name -Path $ISO_Path


$MyDVD = Get-VMDvdDrive $SecondDC
$MyHD = Get-VMHardDiskDrive $SecondDC
$MyNIC = Get-VMNetworkAdapter $SecondDC

Set-VMFirmware $SecondDC -BootOrder $MyDVD,$MyHD,$MyNIC
Set-VMMemory $SecondDC -DynamicMemoryEnabled $false

#Image Server

Set-VMDvdDrive -VMName $SecondDC -Path $LabResourcePath

Invoke-Command -VMName $SecondDC -ScriptBlock {Rename-Computer -NewName 'HDC01';Restart-Computer -Force}
Invoke-Command -VMName $SecondDC -ScriptBlock {Copy-Item -Path D:\* -Recurse -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Force}
Invoke-Command -VMName $SecondDC -ScriptBlock {C:\'Program Files\WindowsPowerShell\Modules\DSCLab.ps1'} -Verbose
Invoke-Command -VMName $SecondDC -ScriptBlock {Get-DnsServerForwarder | Remove-DnsServerForwarder} 

#Setup Conditonal forwarding
Invoke-Command -VMName $Name -ScriptBlock {Import-Module DnsServer;Add-DnsServerConditionalForwarderZone -Name "hydra.org" -ReplicationScope "Forest" -MasterServers '192.168.2.3'} -Credential zephyr\administrator
Invoke-Command -VMName $SecondDC -ScriptBlock {Import-Module DnsServer;Add-DnsServerConditionalForwarderZone -Name "zephyr.org" -ReplicationScope "Forest" -MasterServers '192.168.2.2'} -Credential hydra\administrator



#Build File Server for Hydra.org
$HydraFileServer = 'HFile01'
$SwitchName = 'Internal'
$HardDiskSize = 32GB
$HDPath = 'C:\Hyper-V\Virtual Hard Disks'+'\'+$HydraFileServer+'.vhdx'
$Generation = '2'
$ISO_Path = 'C:\Hyper-V\ISO\WindowsServer2016TechnicalPreview4.ISO'

New-VM -Name $HydraFileServer -SwitchName $SwitchName `
-NewVHDSizeBytes $HardDiskSize `
-NewVHDPath $HDPath -Generation $Generation -MemoryStartupBytes 1024MB

Add-VMDvdDrive -VMName $HydraFileServer -Path $ISO_Path


$MyDVD = Get-VMDvdDrive $HydraFileServer
$MyHD = Get-VMHardDiskDrive $HydraFileServer
$MyNIC = Get-VMNetworkAdapter $HydraFileServer

Set-VMFirmware $HydraFileServer -BootOrder $MyDVD,$MyHD,$MyNIC
Set-VMMemory $HydraFileServer -DynamicMemoryEnabled $false

Invoke-Command -VMName $HydraFileServer -ScriptBlock {Rename-Computer -NewName 'HFile01';Restart-Computer -Force}

Invoke-Command -VMName $HydraFileServer -ScriptBlock {Add-Computer -DomainName hydra -Credential hydra\administrator;Restart-Computer -Force}

#Setup LCM & DSC Pull
New-DscCheckSum -ConfigurationPath "C:\Program Files\WindowsPowerShell\DscService\Modules" -OutPath "C:\Program Files\WindowsPowerShell\DscService\Modules" -Verbose -Force
Update-DscConfiguration -ComputerName HFile01 -Wait -Verbose