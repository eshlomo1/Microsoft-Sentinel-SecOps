Get-ADUser -Filter {EmailAddress -notlike "*"} -Properties EmailAddress | Select Name
