<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 02
  LAB Bulk	User creation 
 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 
#>
$secpass = Read-Host "Passw0rd!" -AsSecureString 
Import-Csv labnames.csv |
foreach {
  $name = "$($_.LastName) $($_.FirstName)"
   
 New-ADUser -GivenName $($_.FirstName) -Surname $($_.LastName) `
 -Name $name -SamAccountName $($_.SamAccountName) `
 -UserPrincipalName "$($_.SamAccountName)@manticore.org" `
 -AccountPassword $secpass -Path "cn=Users,dc=Manticore,dc=org" `
 -Enabled:$true
}
