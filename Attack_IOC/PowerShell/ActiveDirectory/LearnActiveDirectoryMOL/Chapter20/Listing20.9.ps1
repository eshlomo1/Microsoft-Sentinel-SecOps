
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
foreach ($dc in $dom.DomainControllers){
 Get-WmiObject -Class Win32_OperatingSystem -ComputerName $dc |
 Select PSComputerName,  
 @{Name='LocalTime'; Expression={$_.ConvertToDateTime($_.LocalDateTime)} }
}