break



# Delete a batch of users
Get-ADUser -Filter 'Office -eq "MVA"' | Remove-ADUser -WhatIf

Get-ADUser -Filter 'Office -eq "MVA"' | Remove-ADUser

Get-ADUser -Filter 'Office -eq "MVA"' | Remove-ADUser -Confirm:$false



# Empty the AD Recycle Bin (ONLY IN A LAB!)
Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter "(!name=Deleted Objects)" -IncludeDeletedObjects | 
    Remove-ADObject -Confirm:$false




#------------------------------------------------------------------------------
# Deleting computer objects recursively.  They are a container!
# Some (like clusters) may contain child objects.
#------------------------------------------------------------------------------


New-ADComputer MP3Server
Get-ADComputer MP3Server
Remove-ADComputer MP3Server -WhatIf
Get-ADComputer MP3Server | Remove-ADObject -Recursive







#------------------------------------------------------------------------------
# Delete objects by batches
#------------------------------------------------------------------------------

do {
    $query = Get-ADObject -LDAPFilter '(&(objectClass=foo)(attribute=value))' -Server dc1.contoso.com -ResultSetSize 5000
    $query | Remove-ADObject -Confirm:$False -Recurse
    Start-Sleep -Seconds (15*60)
} while ($query)


