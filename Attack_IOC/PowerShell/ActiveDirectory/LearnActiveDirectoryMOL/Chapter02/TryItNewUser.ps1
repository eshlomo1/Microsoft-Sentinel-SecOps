<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 02
  LAB Complete the Try it Now sections	User creation 
 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 
#>

$secpass = Read-Host "Passw0rd!" -AsSecureString 
New-ADUser -Name "GREEN Dave" -SamAccountName dgreen `
-UserPrincipalName "dgreen@manticore.org" -AccountPassword $secpass `
-Path "cn=Users,dc=Manticore,dc=org"  -Enabled:$true

$secpass = Read-Host "Passw0rd!" -AsSecureString 
New-ADUser -Name "GREEN Jo" -SamAccountName jgreen `
-UserPrincipalName "jgreen@manticore.org" -AccountPassword $secpass `
-Path "cn=Users,dc=Manticore,dc=org"  -Enabled:$true

$secpass = Read-Host "Passw0rd!" -AsSecureString 
New-ADUser -Name "GREEN Fred" -SamAccountName fgreen `
-UserPrincipalName "fgreen@manticore.org" -AccountPassword $secpass `
-Path "cn=Users,dc=Manticore,dc=org"  -Enabled:$true

$secpass = Read-Host "Password!" -AsSecureString 
New-ADUser -Name "GREEN Mike" -SamAccountName mgreen `
-UserPrincipalName "mgreen@manticore.org" -AccountPassword $secpass `
-Path "cn=Users,dc=Manticore,dc=org"  -Enabled:$true