Configuration LCMPull
{
	Node Localhost
	{
		LocalConfigurationManager{
			ConfigurationMode = 'ApplyandAutoCorrect'
			ConfigurationID = [GUID]::NewGuid().Guid
			RefreshFrequencyMins = 120
			ConfigurationModeFrequencyMins = 240
			RefreshMode = 'Pull'
			RebootNodeIfNeeded = $false
			DownloadManagerName = 'WebDownloadManager'
			DownloadManagerCustomData = @{
				ServerUrl = 'https://psv52012r2pull4.contoso.com:8080/PSDSCPullServer.svc'
				AllowUnsecureConnection = 'false'
			}    
			
		}
	}
}