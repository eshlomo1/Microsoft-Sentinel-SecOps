Get-ADUser -Identity wgreen |
Rename-ADObject -NewName "GREEN Bill"

Get-ADUser -Identity wgreen -Properties * |
Set-ADUser -DisplayName "GREEN Bill" -SamAccountName bgreen `
-GivenName "Bill"  
