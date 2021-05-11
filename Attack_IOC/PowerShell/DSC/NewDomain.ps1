configuration NewDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred,
        [string]$IPAddress,
        [string]$DefaultGateway,
        [string]$TimeZone = 'Central Standard Time'


    )             
            
    Import-DscResource -ModuleName xActiveDirectory,xPSDesiredStateConfiguration,xNetworking,xComputerManagement,xTimeZone
    
            
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename             
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
        
        xIPAddress NewIPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
 
        }

        xDefaultGatewayAddress NewDefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = 'Ethernet'
            Address = $Node.DefaultGateway
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
        #WindowsFeature ADDSTools            
        #{             
        #    Ensure = "Present"             
        #   Name = "RSAT-ADDS"             
        #}            
            
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
            Nodename = 'S1'          
            Role = "Primary DC"             
            DomainName = "Source.org"             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.2'
            DefaultGateway = '192.168.2.1'            
        }                      
    )             
}             
            
NewDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName Manticore\administrator `
        -Message "New Domain Admin Credential")
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path C:\DSC\NewDomain\ –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path C:\DSC\NewDomain\ -Verbose 