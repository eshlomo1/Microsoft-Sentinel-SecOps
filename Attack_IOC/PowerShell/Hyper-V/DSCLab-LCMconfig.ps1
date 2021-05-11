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
                ServerURL = 'http://zdc01.zephyr.org:8080/PSDSCPullServer.svc/'
                AllowUnsecureConnection = $true
            }
		
	}
}

# Computer list 
$ComputerName='DC02', 'DC03'

# Create Guid for the computers
$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
LCM_HTTPPULL -ComputerName $ComputerName -Guid $guid -OutputPath $env:SystemDrive\DSC\HTTP