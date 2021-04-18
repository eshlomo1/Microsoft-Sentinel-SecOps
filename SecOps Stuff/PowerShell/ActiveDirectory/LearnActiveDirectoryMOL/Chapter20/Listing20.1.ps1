##
## Test FSMO role holders
##
$for = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
Test-Connection -ComputerName $for.SchemaRoleOwner -Count 2
Test-Connection -ComputerName $for.NamingRoleOwner -Count 2

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
Test-Connection -ComputerName $dom.PdcRoleOwner -Count 2 
Test-Connection -ComputerName $dom.InfrastructureRoleOwner -Count 2
Test-Connection -ComputerName $dom.RidRoleOwner -Count 2