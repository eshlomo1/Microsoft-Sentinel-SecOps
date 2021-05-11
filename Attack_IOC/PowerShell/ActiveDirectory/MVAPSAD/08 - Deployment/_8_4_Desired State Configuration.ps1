#Requires -RunAsAdministrator 

<#
Dependencies:
 Run as administrator
 Remoting enabled (default on 2012)
 Execution policy of RemoteSigned (or otherwise allowing scripts) (default on 2012 R2)
 PowerShell DSC Resource Kit
   http://gallery.technet.microsoft.com/xActiveDirectory-f2d573f3
   The xActiveDirectory module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit
#>

Break


# View the DSC resources
Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\xActiveDirectory\DSCResources'

<#
Note that this is a simple PUSH DSC demo. A PULL server configuration would host the module files for pull.
Also note this method uses clear text passwords. Use certificates to encrypt credentials in production.
Copy the resource module files to the target manually
First enabled firewall rule "File and Printer Sharing (SMB-in)"
Copy-Item -Recurse -Force -Verbose `
    -Path 'C:\Program Files\WindowsPowerShell\Modules\xActiveDirectory' `
    -Destination '\\cvmember3\c$\Program Files\WindowsPowerShell\Modules\xActiveDirectory'
#>

Set-Location "$Home\Documents\MVA\08 - Deployment"

# DCPROMO PowerShell DSC Style
configuration DSCPromo
{ 
   param 
    ( 
        [Parameter(Mandatory)] 
        [pscredential]$safemodeAdministratorCred, 
        [Parameter(Mandatory)] 
        [pscredential]$domainCred
    ) 

    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Nodename
    { 
        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services" 
        } 
        xADDomainController NewDC
        { 
            DomainName = $Node.DomainName 
            DomainAdministratorCredential = $domainCred 
            SafemodeAdministratorPassword = $safemodeAdministratorCred 
            DependsOn = "[WindowsFeature]ADDSInstall" 
        } 
    } 
} 

# Configuration Data for AD  
$ConfigData = @{ 
    AllNodes = @( 
        @{
            Nodename = "CVMEMBER3"
            DomainName = "cohovineyard.com"
            RetryCount = 3
            RetryIntervalSec = 10
            PSDscAllowPlainTextPassword = $true
        } 
    ) 
} 

DSCPromo -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' -Message "New DC Safe Mode Admin Credentials") `
    -domainCred (Get-Credential -UserName cohovineyard\administrator -Message "Domain Admin Credentials")

# The MOF has clear text passwords using this method!
# notepad .\DSCPromo\CVMEMBER3.mof

# Apply the configuration
Start-DscConfiguration -Wait -Force -Verbose -ComputerName CVMEMBER3 -Path .\DSCPromo

# Reboot the new DC
Restart-Computer -ComputerName CVMEMBER3 -Force -Wait -For PowerShell

# Verify the new DC is operational
Invoke-Command -ComputerName CVMEMBER3 `
    -ScriptBlock {Get-ADDomainController -Filter * | ft HostName, IPv4Address, IsGlobalCatalog -AutoSize}






### Reset demo ###

$ScriptBlock = {
    Remove-Item C:\Windows\System32\Configuration\Current.mof, C:\Windows\System32\Configuration\backup.mof, C:\Windows\System32\Configuration\Previous.mof
}
Invoke-Command -ComputerName CVMEMBER3 -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue
Remove-Item .\DSCPromo -Recurse -Force -Confirm:$false

# DCPROMO down
$cred = Get-Credential Cohovineyard\Administrator

$error.Clear()
Invoke-Command –ComputerName cvmember3.cohovineyard.com –ScriptBlock {

    Uninstall-ADDSDomainController -Confirm:$false `
       -LocalAdministratorPassword (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force) `
       -DemoteOperationMasterRole:$true `
       -Credential $using:cred `
       -Force:$true
}

If ($error) {break}

# Give the server time to go down
Start-Sleep -Seconds 5

# The DC removal also removes the host A record in DNS.
# Therefore we tell the Uninstall to do the reboot by omitting the switch -NoRebootOnCompletion,
# and then loop until we can confirm the server is reachable again and services are started.
Do { Start-Sleep -Seconds 1 }
Until (Get-CIMInstance Win32_Bios -ComputerName cvmember3.cohovineyard.com -ErrorAction SilentlyContinue)

# Uninstall the AD DS & DNS roles
Import-Module ServerManager
Uninstall-WindowsFeature –Name AD-Domain-Services, DNS, RSAT-AD-Tools, RSAT-AD-PowerShell `
    –ComputerName cvmember3.cohovineyard.com `
    -IncludeManagementTools `
    -Confirm:$false

Restart-Computer cvmember3.cohovineyard.com `
    -Wait -For PowerShell -Force -Confirm:$false

# Remove the server object under sites
Get-ADObject -Filter 'Name -eq "CVMEMBER3" -and ObjectClass -eq "server"' `
    -SearchBase ('CN=Sites,'+(Get-ADRootDSE).ConfigurationNamingContext) |
    Remove-ADObject -Confirm:$false

# Remove the SPNs on the computer object
$DCSPNs = @'
E3514235-4B06-11D1-AB04-00C04FC2DCD2/82929295-ec65-4cd8-a9cf-9584cb32e091/CohoVineyard.com
NtFrs-88f5d2bd-b646-11d2-a6d3-00c04fc9b232/CVMEMBER3.CohoVineyard.com
Dfsr-12F9A27C-BF97-4787-9364-D31B6C55EB04/CVMEMBER3.CohoVineyard.com
'@
Get-ADComputer CVMEMBER3 -Properties ServicePrincipalName |
    Select-Object -ExpandProperty ServicePrincipalName |
    Where-Object {$_ -in ($DCSPNs -split "`r`n")} |
    ForEach-Object {Set-ADComputer CVMEMBER3 -Remove @{ServicePrincipalName=$_}}

# Verify no SRV records in DNS
Get-DnsServerResourceRecord -Name CVMEMBER3 -ZoneName cohovineyard.com
Get-DnsServerResourceRecord -Name CVMEMBER3 -ZoneName _msdcs.cohovineyard.com
Get-DnsServerResourceRecord -RRType Ns -ZoneName cohovineyard.com
Get-DnsServerResourceRecord -RRType Ns -ZoneName _msdcs.cohovineyard.com

Get-WindowsFeature -ComputerName cvmember3.cohovineyard.com | 
    Where-Object Installed | Format-Table Name

Get-ADDomainController -Filter * -Server cvdcr2 | Format-Table Name, Site, IPv4Address -AutoSize
