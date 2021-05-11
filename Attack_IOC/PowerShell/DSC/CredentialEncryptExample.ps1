Configuration CredentialEncryptExample {
    Param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )
    
    Node $AllNodes.NodeName
    {
        Group TestGroup{
            GroupName = 'TestGroup'
            Members = 'source\jduffney'
            Ensure = 'Present'
            Credential = $Credential
        }
    }
    
    LocalConfigurationManager {
        CertificateID = $node.Thumbprint
    }
}

$configdata = @{
    AllNodes = @(
     @{
      NodeName = 'S3'
      PSDSCAllowPlainTextPassword = $false
      Certificatefile = 'c:\Certs\S3.cer'
      Thumbprint = 'BB791ED7FD50ADA3C38C5CBB28F8888CB34D717F'   
     }
    )
}

CredentialEncryptExample -configurationdata $configdata `
-Credential (Get-Credential -Message 'Enter Credential for configuration')

Set-DscLocalConfigurationManager -Path c:\DSC\CredentialEncryptExample -ComputerName S3 -Verbose

Start-DscConfiguration -Path c:\DSC\CredentialEncryptExample -ComputerName S3 -Wait -Verbose