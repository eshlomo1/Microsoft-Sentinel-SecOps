configuration DscPullServer
{
param
(
[string[]]$NodeName = 'localhost',

[ValidateNotNullOrEmpty()]
[string] $certificateThumbPrint,

[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[string] $RegistrationKey
)

Import-DSCResource -ModuleName PSDesiredStateConfiguration
Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
        Ensure = 'Present'
        Name = 'DSC-Service'
        }

        xDscWebService PSDSCPullServer
        {
        Ensure = 'present'
        EndpointName = 'PSDSCPullServer'
        Port = 8080
        PhysicalPath = "$env:SystemDrive\inetpub\PSDSCPullServer\"
        CertificateThumbPrint = $certificateThumbPrint
        ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
        ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
        State = 'Started'
        DependsOn = '[WindowsFeature]DSCServiceFeature'
        UseSecurityBestPractices = $true
        }
        
        File RegistrationKeyFile
        {
        Ensure = 'Present'
        Type = 'File'
        DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
        Contents = $RegistrationKey
        }
    }

}


$guid = [guid]::newGuid()

$cert = Get-ChildItem Cert:\LocalMachine\My | where {$_.FriendlyName -eq 'PSDSCPullServerCert'}

DscPullServer -certificateThumbPrint $cert.Thumbprint -RegistrationKey $guid -OutputPath c:\dsc

Start-DscConfiguration -Path C:\dsc -Wait -Verbose -Force