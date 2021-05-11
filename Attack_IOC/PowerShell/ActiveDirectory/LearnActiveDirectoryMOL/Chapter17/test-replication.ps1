<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 17

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()                                  #1

$dom.FindAllDomainControllers() |                           
foreach {
 $_.Name
 $contextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::DirectoryServer                 
 
$context = New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $contextType, $($_.Name)                   
 
$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)          
 
$dc.GetAllReplicationNeighbors() | 
 select PartitionName, SourceServer, UsnLastObjectChangeSynced,    
 LastSuccessfulSync, LastAttemptedSync, LastSyncMessage,
 ConsecutiveFailureCount
}
