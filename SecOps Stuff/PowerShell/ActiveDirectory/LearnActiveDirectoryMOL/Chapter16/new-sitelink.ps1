<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 16

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>
## get current forest and set context
$for = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$fortyp = [System.DirectoryServices.ActiveDirectory.DirectoryContexttype]"forest"
$forcntxt = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext($fortyp, $for)

$link = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink -ArgumentList $forcntxt, "MyNewSite3-MyNewSite4"

$site1 = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::FindByName($forcntxt, "MyNewSite3")
$site2 = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::FindByName($forcntxt, "MyNewSite4")

$link.Sites.Add($site1)
$link.Sites.Add($site2)

$link.Cost = 150
$link.ReplicationInterval = "01:00:00"   ## 1 hour   24x7
$link.Save()

$linkde = $link.GetDirectoryEntry()
$linkde.Description = "Links sites MyNewSite3 and MyNewSite4"
$linkde.SetInfo()