break

# http://blogs.technet.com/b/askds/archive/2013/06/04/two-lines-that-can-save-your-ad-from-a-crisis.aspx

# Do this for users, computers, groups, OUs, etc.

New-ADUser ProtectMe

# View the property
Get-ADuser ProtectMe -Properties ProtectedFromAccidentalDeletion

# View ACL on an object
Get-ADUser ProtectMe -Properties NTSecurityDescriptor |
    Select-Object -ExpandProperty NTSecurityDescriptor |
    Select-Object -ExpandProperty Access | ogv

# Turn on delete protection
Get-ADUser -Identity ProtectMe | Set-ADObject -ProtectedFromAccidentalDeletion:$true

# View the property
Get-ADuser ProtectMe -Properties ProtectedFromAccidentalDeletion

# View new ACL with "Everone/Deny/Delete"
Get-ADUser ProtectMe -Properties NTSecurityDescriptor |
    Select-Object -ExpandProperty NTSecurityDescriptor |
    Select-Object -ExpandProperty Access | ogv


# Now go forth and protect thy kingdom from junior admins everywhere.
Get-ADUser -Filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$true
Get-ADGroup -Filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$true
Get-ADOrganizationalUnit -Filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$true

# This will make it a pain to script deletions.  ERROR.
Remove-ADUser ProtectMe -Confirm:$false

# Get object, remove protection (with passthru), then delete
Get-ADUser ProtectMe |
    Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru |
    Remove-ADUser -Confirm:$false

# Now gone
Get-ADUser ProtectMe
