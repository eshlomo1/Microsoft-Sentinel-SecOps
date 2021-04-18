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

$site = "MyNewSite2"
$subnetlocation = "Building X"
$subnetname = "10.55.0.0/24"

## create subnet and link to the site
$subnet = New-Object System.DirectoryServices.ActiveDirectory.ActiveDirectorySubnet($forcntxt, $subnetname, $site)
$Subnet.Location = $subnetlocation
$subnet.Save()