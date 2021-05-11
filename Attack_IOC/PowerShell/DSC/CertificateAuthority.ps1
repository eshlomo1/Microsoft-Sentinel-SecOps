Configuration CertificateAuthority
{        

    Import-DscResource -ModuleName xAdcsDeployment,PSDesiredStateConfiguration,xNetworking,xComputerManagement,xTimeZone
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename
    {  
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
        WindowsFeature ADCS-Cert-Authority
        {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
        }
        xADCSCertificationAuthority ADCS
        {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }
        WindowsFeature ADCS-Web-Enrollment
        {
            Ensure = 'Present'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        xADCSWebEnrollment CertSrv
        {
            Ensure = 'Present'
            Name = 'CertSrv'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        } 
    }  
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'S2'          
            Role = "PKI"             
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.4'
            Credential = (Get-Credential -UserName 'source\administrator')
            DefaultGateway = '192.168.2.1'
        }                      
    )             
}

CertificateAuthority -ConfigurationData $ConfigData

Start-DscConfiguration -Wait -Force -Path C:\DSC\CertificateAuthority\ -Verbose 