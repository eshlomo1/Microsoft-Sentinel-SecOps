$WindowsUpdateAgentVer = (Get-ItemProperty -Path 'C:\Windows\System32\wuaueng.dll' -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
if ($WindowsUpdateAgentVer -eq '7.6.7600.256' -or $WindowsUpdateAgentVer -eq '7.6.7600.320'){
     Write-Host "Installed"
     }
