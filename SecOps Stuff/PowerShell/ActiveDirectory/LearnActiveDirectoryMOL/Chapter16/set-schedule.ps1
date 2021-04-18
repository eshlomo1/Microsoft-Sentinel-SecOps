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

$link = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink]::FindByName($forcntxt, "MyNewSite3-MyNewSite4")

$sched = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule
$sched.ResetSchedule()
$sched.SetDailySchedule("Eighteen", "Zero", "TwentyThree", "FortyFive")

$link.InterSiteReplicationSchedule = $sched
$link.Save()

$days = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
$sched.SetSchedule($days, "Twelve", "Zero", "Thirteen", "FortyFive")

$link.InterSiteReplicationSchedule = $sched
$link.Save()