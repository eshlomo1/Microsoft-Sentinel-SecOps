configuration LabDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred,
        [pscredential]$domainCred2

    )             
            
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource –ModuleName xPSDesiredStateConfiguration
    Import-DscResource -Module xNetworking
    Import-DscResource -module xDHCpServer
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    
            
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename             
    {             
            
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }
        
        xIPAddress NewIPAddress
        {
            IPAddress      = "192.168.2.2"
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

        
        WindowsFeature DHCP {
            DependsOn = '[xIPAddress]NewIpAddress'
            Name = 'DHCP'
            Ensure = 'PRESENT'
            IncludeAllSubFeature = $true                                                                                                                              
 
        }  
 
        WindowsFeature DHCPTools
        {
            DependsOn= '[WindowsFeature]DHCP'
            Ensure = 'Present'
            Name = 'RSAT-DHCP'
            IncludeAllSubFeature = $true
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
        
        xDhcpServerScope Scope
        {
         DependsOn = '[WindowsFeature]DHCP'
         Ensure = 'Present'
         IPEndRange = '192.168.2.200'
         IPStartRange = '192.168.2.100'
         Name = 'PowerShellScope'
         SubnetMask = '255.255.255.0'
         LeaseDuration = '00:08:00'
         State = 'Active'
         AddressFamily = 'IPv4'
        } 
 
        xDhcpServerOption Option
     {
         Ensure = 'Present'
         ScopeID = '192.168.2.0'
         DnsDomain = 'zephyr.org'
         DnsServerIPAddress = '192.168.2.2'
         AddressFamily = 'IPv4'
         Router = '192.168.2.1'
     }                    
            
    }

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
        DomainAdministratorCredential = $domainCred2            
        SafemodeAdministratorPassword = $safemodeAdministratorCred            
        DatabasePath = 'C:\NTDS'            
        LogPath = 'C:\NTDS'            
        DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
    }
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
        }

        xDscWebService PSDSCComplianceServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServer"
            Port                    = 9080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
        }

    }                  
}
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'ZDC01'          
            Role = "Primary DC"             
            DomainName = "Zephyr.org"             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true            
        }
        @{             
            Nodename = 'HDC01'        
            Role = "Second Domain"             
            DomainName = "Hydra.org"             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true            
        }                       
    )             
}             
            
LabDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName Zephyr\administrator `
        -Message "New Domain Admin Credential") `
    -domainCred2 (Get-Credential -UserName hydra\administrator `
        -Message "New Domain Admin Credential")
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path C:\DSC\LabDomain\ –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path C:\DSC\LabDomain\ -Verbose 