##
## test domain controller time
##
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$dom.DomainControllers | select Name, CurrentTime