[DSCLocalConfigurationManager()]
Configuration LCM_HTTPPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid
        )      	
	Node $ComputerName {
	
		Settings{
		
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            }

            ConfigurationRepositoryWeb DSCHTTP {
                #ConfigurationNames = 'DSCHTTP'
                ServerURL = 'http://HDC01.Hydra.org:8080/PSDSCPullServer.svc/'
                AllowUnsecureConnection = $true
            }
		
	}
}

# Computer list 
$ComputerName='HFile01'

# Create Guid for the computers
$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
LCM_HTTPPULL -ComputerName $ComputerName -Guid $guid -OutputPath c:\DSC\HTTP

Set-DSCLocalConfigurationManager -ComputerName 'HFile01' -Path c:\DSC\HTTP –Verbose