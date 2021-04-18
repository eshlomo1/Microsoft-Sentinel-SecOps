<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 16

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>
$for = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$for.sites | Format-Table Name, SiteLinks