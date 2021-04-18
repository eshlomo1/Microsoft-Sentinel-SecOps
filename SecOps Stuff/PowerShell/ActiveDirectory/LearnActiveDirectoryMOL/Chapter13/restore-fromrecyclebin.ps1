Get-ADObject -IncludeDeletedObjects -Filter {Name -like '*Test*' -AND objectclass -eq 'organizationalunit'} | where Deleted | Restore-ADObject

Get-ADObject -IncludeDeletedObjects -Properties *  -Filter {LastKnownParent -eq "OU=Test,DC=Manticore,DC=org" -AND objectclass -eq 'user'} | where Deleted | Restore-ADObject