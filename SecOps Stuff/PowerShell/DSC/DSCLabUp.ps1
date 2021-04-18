Configuration DSCLabUp {
    
    param (
        [string[]]$NodeName,        
        [string]$MachineName,
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred        
        )
    
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource –ModuleName xPSDesiredStateConfiguration
    Import-DscResource -Module cNetworking
    Import-DscResource -Module xNetworking
    Import-DscResource -module xDHCpServer
    Import-DscResource -Module xComputerManagement
    Import-DscResource -Module xTimeZone
    
    Node $AllNodes.Where{$_.Role -eq "DomainController"}.Nodename  {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }        

        xComputer NewName {
            Name = $Node.MachineName
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

        cDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
        }        
        
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
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
        
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
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
}

$DNSArray = @('127.0.0.1')


$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'Localhost'          
            Role = "DomainController"
            MachineName = 'ZDC01'
            DomainName = "Zephyr.org"                         
            IPAddress = '192.168.2.2'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = $DNSArray
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true     
        }
                      
    )             
}   

# Save ConfigurationData in a file with .psd1 file extension

DSCLabUp -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
     -Message "New Domain Safe Mode Administrator Password") `
     -domainCred (Get-Credential -UserName Zephyr\administrator `
      -Message "New Domain Admin Credential")

Set-DscLocalConfigurationManager -Path .\DSCLabUp -Verbose -Force
Start-DscConfiguration -ComputerName localhost -wait -force -Verbose -Path .\DSCLabUp
