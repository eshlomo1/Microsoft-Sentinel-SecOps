configuration LabSecondDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred,
        [Parameter(Mandatory)][string]$NewName                  
    )             
            
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -Module xNetworking
    Import-DscResource -module xDHCpServer
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    

    Node $AllNodes.Where{$_.Role -eq "Second Domain"}.Nodename             
    { 
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }

        xComputer NewName
        {
            Name = $NewName
 
        }
        
        xIPAddress NewIPAddress
        {
            IPAddress      = "192.168.2.3"
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
 
        }

        xDefaultGatewayAddress NewDefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = 'Ethernet'
            Address = '192.168.2.1'
            DependsOn = '[xIPAddress]NewIpAddress'

        }

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }            
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $true
             
        }            
            
        # Optional GUI tools            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
            
        # No slash at end of folder paths            
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }
  }           
}
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = $env:computername          
            Role = "Second Domain"             
            DomainName = "Hydra.org"             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true            
        }                       
    )             
}             
            
LabSecondDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName Hydra\administrator `
        -Message "New Domain Admin Credential") `
    -NewName 'HDC01'            
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path C:\DSC\LabSecondDomain\ –Verbose           
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path C:\DSC\LabSecondDomain\ -Verbose 