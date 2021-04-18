break

##### This is a REALLY rough draft of a cloning proof-of-concept.  It mostly worked once in my lab.
##### Treat this accordingly.


# Virtual Domain Controller Cloning in Windows Server 2012
# http://blogs.technet.com/b/askpfeplat/archive/2012/10/01/virtual-domain-controller-cloning-in-windows-server-2012.aspx

# MUST RUN ELEVATED
break


# VmGenerationId is a feature of 2012 that makes virtual DC cloning possible.

# VmGenId is only stored on the computer object of the DC locally
Get-ADComputer -Filter * -Properties msDS-GenerationID -SearchBase (Get-ADDomain).DomainControllersContainer |
    Select-Object Name, msDS-GenerationID | ogv

# Must query VmGenId from each DC individually
Get-ADDomainController -Filter * |
    Select-Object HostName,InvocationID,@{name="VMGenID";expression={(Get-ADObject -Identity $_.ComputerObjectDN -Server $_.HostName -Properties msDS-GenerationID | Select-Object -ExpandProperty msDS-GenerationID) -join '-'}},Site,IPv4Address |
    Out-GridView

# The attribute is a BYTE datatype.
[byte]$b | gm




# This is a rough sketch of the cloning process:

$ClonePath = "Z:\VMs\ClonedDCs"
$OpsDC = "cvdcr2.cohovineyard.com"
$cred = Get-Credential CohoVineyard\Administrator
$OpsDCSession = New-PSSession -ComputerName $OpsDC -Credential $cred

# Select the DC to clone
$TargetDC = Invoke-Command -Session $OpsDCSession -ScriptBlock {
    Get-ADDomainController -Filter * |
        Select-Object Forest,Domain,HostName,Name,InvocationID,@{name="VMGenID";expression={(Get-ADObject -Identity $_.ComputerObjectDN -Server $_.HostName -Properties msDS-GenerationID | Select-Object -ExpandProperty msDS-GenerationID) -join '-'}},Site,IPv4Address,ComputerObjectDN
} |
    Select-Object -Property * -ExcludeProperty PSComputerName,RunspaceID |
    Out-GridView -OutputMode Single -Title "Select DC to clone"

# Select the VM to clone
$HyperVHost = Read-Host "HyperV host for export and import of cloned DCs"
$TargetVM = Get-VM -ComputerName $HyperVHost | Out-GridView -OutputMode Single -Title "Select VM matching the DC to be cloned"

# Add to clonable DC group
Invoke-Command -Session $OpsDCSession -ScriptBlock {
    $CDC = Get-ADGroup -Identity "Cloneable Domain Controllers" -Server $using:TargetDC.HostName
    $CDC | Add-ADGroupMember -Members $using:TargetDC.ComputerObjectDN
    $CDC | Get-ADGroupMember
}

# Assuming DC is online
# Open session to target clone DC
$TargetDCSession = New-PSSession -ComputerName $TargetDC.HostName -Credential $cred

# Drop the cloning files
Invoke-Command -Session $TargetDCSession -ScriptBlock {

    Get-ADDCCloningExcludedApplicationList
    Get-ADDCCloningExcludedApplicationList -GenerateXml -Force

    $NTDSPath = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\ -Name "DSA Working Directory" |
        Select-Object -ExpandProperty "DSA Working Directory"
    Remove-Item "$NTDSPath\DCCloneConfig*.xml" -Confirm:$false
    New-ADDCCloneConfigFile

    Get-ChildItem $NTDSPath | Format-Table -AutoSize
}

# Shutdown the DC to be cloned
Invoke-Command -Session $TargetDCSession -ScriptBlock {
    Stop-Computer -Force
}

# Wait for the VM to shutdown
While ((Get-VM $TargetVM.VMId).State -ne "Off") {
    Start-Sleep 1
}

# Export target VM
$ClonedVMSource = "$ClonePath\$($TargetVM.VMName)_CloneSource"
Export-VM -ComputerName $HyperVHost -Name $TargetVM.VMName -Path $ClonedVMSource
# Start up the source VM
Start-VM -ComputerName $HyperVHost -Name $TargetVM.VMName
Do { Start-Sleep 1 }
Until (Get-WMIObject -Class Win32_Bios -ComputerName $TargetDC.HostName -Credential $cred -ErrorAction SilentlyContinue)

#Import cloned VM
### Add lines here to clean up all of the file names showing the old VM name
$ClonedVMDestination = "$ClonePath\1"
$ClonedVM = Import-VM -Path (Get-ChildItem -Path $ClonedVMSource -Include *.xml -Recurse) `
    -ComputerName $HyperVHost -Copy -GenerateNewId `
    -VirtualMachinePath $ClonedVMDestination `
    -VhdDestinationPath $ClonedVMDestination `
    -SmartPagingFilePath $ClonedVMDestination `
    -SnapshotFilePath $ClonedVMDestination
Rename-VM -VM $ClonedVM -NewName "$($TargetVM.VMName)_Clone1" -ComputerName $HyperVHost

# Start up the cloned VM
# Must have DHCP for the first boot.
Start-VM -ComputerName $HyperVHost -Name $ClonedVM.VMName

# Cloning process runs for a few minutes
# DC reboots
# Cloning process runs for a few more minutes
# DC reboots again
Do { Start-Sleep 5 }
Until (Invoke-Command -Session $OpsDCSession -ScriptBlock {Get-ADDomainController "$($using:TargetDC.Name)-CL0001" -Server $($using:TargetDC.HostName)})

# Errors?
#  Domain controller cloning fails and the server restarts in DSRM in Windows Server 2012
#  http://support.microsoft.com/kb/2742844
#  Virtualized Domain Controller Troubleshooting
#  http://technet.microsoft.com/en-us/library/jj574207.aspx

# Set static IP and DNS information
# We are interrupting the network connection that we are using to set the network address.
# Must use -InDisconnectedSession parameter so that it doesn't try to confirm success.
Invoke-Command -ComputerName "$($TargetDC.Name)-CL0001" -Credential $cred -ScriptBlock {
    Get-NetIPInterface -AddressFamily IPv4 -Dhcp Enabled -ConnectionState Connected | 
    New-NetIPAddress -IPAddress 10.12.1.201 -PrefixLength 8 -AddressFamily IPv4 |
    Set-DnsClientServerAddress -ServerAddresses @("10.12.1.1","10.9.1.1")
    Register-DnsClient
} -InDisconnectedSession
# Test-Connection 10.12.1.201

# NetLogon API
# http://msdn.microsoft.com/en-us/library/bb432349(v=vs.85).aspx

