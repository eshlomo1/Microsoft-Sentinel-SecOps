##
## Test domain controllers
##
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
foreach ($dc in $dom.DomainControllers){
Test-Connection -ComputerName $dc -Count 2 
}