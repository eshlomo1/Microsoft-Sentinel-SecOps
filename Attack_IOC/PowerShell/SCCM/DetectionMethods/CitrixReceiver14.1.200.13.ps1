$osarch = (gwmi win32_operatingsystem).osarchitecture
if ($osarch -eq "64-bit") {
	$ReceiverVersion = (Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginPackWeb' -ErrorAction SilentlyContinue).DisplayVersion
	if ($ReceiverVersion -eq '14.1.200.13') {
		Write-Host 'Installed'
		}
} else {
$ReceiverVersion = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginPackWeb' -ErrorAction SilentlyContinue).DisplayVersion
	if ($ReceiverVersion -eq '14.1.200.13') {
		Write-Host 'Installed'
		}
}
