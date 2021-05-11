break

###############################################################################
# Working with the deployment module
###############################################################################

Get-Module a* -ListAvailable
Import-Module ADDSDeployment
Get-Command -Module ADDSDeployment
help Test-ADDSDomainControllerInstallation

###############################################################################
# DCPROMO UP: Create a new DC on a member server in the domain
###############################################################################

# Prompt for credentials to reuse throughout the script
$cred = Get-Credential Cohovineyard\Administrator

# Echo the date for reference in the console output
Get-Date

# Query the current list of domain controllers before the new one
Get-ADDomainController -Filter * |
    Format-Table Name, Site, IPv4Address -AutoSize

# Import the module containing Get-WindowsFeature
Import-Module ServerManager

# List the currently installed features on the remote server
Get-WindowsFeature -ComputerName cvmember1.cohovineyard.com | 
    Where-Object Installed | Format-Table Name

# Install the role for AD-Domain-Services
Install-WindowsFeature –Name AD-Domain-Services `
    –ComputerName cvmember1.cohovineyard.com `
    -IncludeManagementTools

# List the currently installed features on the remote server
# Notice AD-Domain-Services is now in the list
Get-WindowsFeature -ComputerName cvmember1.cohovineyard.com | 
    Where-Object Installed | Format-Table Name

# Promote a new domain controller in the existing domain
# Adjust the parameters to meet your own needs
# Notice we're going to handle the reboot ourselves
#####    BIG THING TO NOTICE    #####
# Notice that the -Credential parameter variable is prefaced with "$using:".
# This is a PS v3 feature, and it is required when passing variables
# into a remote session.  Invoke-Command is based on PowerShell remoting.
# Any other parameters that you turn into variables will need "$using:".
Invoke-Command –ComputerName cvmember1.cohovineyard.com –ScriptBlock {

    Import-Module ADDSDeployment;

    Install-ADDSDomainController `
        -NoGlobalCatalog:$false `
        -CreateDnsDelegation:$false `
        -CriticalReplicationOnly:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainName "CohoVineyard.com" `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$true `
        -ReplicationSourceDC "CVDC1.CohoVineyard.com" `
        -SiteName "Ohio" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true `
        -Credential $using:cred `
        -Confirm:$false `
        -SafeModeAdministratorPassword `
            (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force)
}

# We are going to manage the restart ourselves.
Restart-Computer cvmember1.cohovineyard.com `
    -Wait -For PowerShell -Force -Confirm:$false

# Once fully restarted and promoted, query for a fresh list of DCs.
# Notice our new DC in the list.
Get-ADDomainController -Filter * |
    Format-Table Name, Site, IPv4Address -AutoSize

# Echo the date and time for job completion.
Get-Date