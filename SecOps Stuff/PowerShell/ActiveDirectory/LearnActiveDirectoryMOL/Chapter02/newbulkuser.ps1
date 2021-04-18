<#
 Code listings from:
  Active Directory Management in a Month of Lunches
  Chapter 02
  2.3	User creation in bulk 
 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 
#>
$secpass = Read-Host "Password" -AsSecureString 
Import-Csv c:\temp\names.csv |
foreach {
  $name = "$($_.FirstName) $($_.LastName)"
   
 New-ADUser -GivenName $($_.FirstName) -Surname $($_.LastName) `
 -Name $name -SamAccountName $($_.SamAccountName) `
 -UserPrincipalName "$($_.SamAccountName)@manticore.org" `
 -AccountPassword $secpass -Path "cn=Users,dc=Manticore,dc=org" `
 -Enabled:$true -Server hydra.manticore.org -Credential hydra\administrator
}
