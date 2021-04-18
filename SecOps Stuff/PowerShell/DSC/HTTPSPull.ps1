configuration HTTPSPull
{
   param             
    (            
        [string]$IPAddress,
        [string]$DefaultGateway,
        [string]$TimeZone = 'Central Standard Time'


    ) 
    
    Import-DscResource -ModuleName xActiveDirectory,xPSDesiredStateConfiguration,xNetworking,xComputerManagement,xTimeZone

    node $AllNodes.Where{$_.Role -eq "HTTPSPull"}.NodeName
    {
        xTimeZone SystemTimeZone {
            TimeZone = $TimeZone
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
        
        xComputer JoinDomain 
        { 
            Name          = $Node.Name  
            DomainName    = $Node.Domain
            Credential    = $Node.Credential
        }         
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'S3'          
            Role = "HTTPSPull"             
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.5'
            Credential = (Get-Credential -UserName 'source\administrator')
            DefaultGateway = '192.168.2.1'
        }                      
    )             
}

HTTPSPull -ConfigurationData $ConfigData

Start-DscConfiguration -Wait -Force -Path C:\DSC\HTTPSPull\ -Verbose 