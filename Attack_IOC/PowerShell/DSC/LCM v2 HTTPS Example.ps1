[DscLocalConfigurationManager()]
Configuration LCMPull {
	Node Localhost {
		Settings {
			ActionAfterReboot = 'ContinueConfiguration'
			AllowModuleOverwrite = $true
			ConfigurationID = [GUID]::NewGuid().Guid
			ConfigurationMode = 'ApplyAndAutoCorrect'
			ConfigurationModeFrequencyMins = 15
			RefreshFrequencyMins = 30
			StatusRetentionTimeInDays = 7
			RebootNodeIfNeeded = $true
			RefreshMode = 'Pull'      
		}
		ConfigurationRepositoryWeb PullServer {
			ServerUrl = 'https://psv52012r2pull4.contoso.com:8080/PSDSCPullServer.svc'
			AllowUnsecureConnection = 'false'
		}
	}
}