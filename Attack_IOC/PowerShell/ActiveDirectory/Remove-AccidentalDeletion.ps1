# Get object, remove protection (with passthru), then delete
Get-ADUser ProtectMe |
    Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru |
    Remove-ADUser -Confirm:$false
