Import-Csv -Path C:\Scripts\officechange.csv |
foreach {
 Set-ADUser -Identity $_.samaccountname -Office $_.Office `
 -StreetAddress $_.StreetAddress -POBox $_.POBox -City $_.City `
  -State $_.State -PostalCode $_.Zip  -Country $_.Country
} 
