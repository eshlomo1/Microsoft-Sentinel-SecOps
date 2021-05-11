##
## Test global catalog
##
$for = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
foreach ($gc in $for.GlobalCatalogs){
Test-Connection -ComputerName $gc -Count 2 
}