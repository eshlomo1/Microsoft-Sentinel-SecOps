break


################
### REPADMIN ###
################

# /ShowObjMeta
# Get-ADReplicationAttributeMetadata
# Returns the replication metadata for one or more Active Directory replication partners.
repadmin /ShowObjMeta localhost "CN=Administrator,CN=Users,DC=cohovineyard,DC=com"
# Wrapped Table
Get-ADuser administrator |
 Get-ADReplicationAttributeMetadata -Server localhost |
 Format-Table LocalChangeUsn, LastOriginatingChangeDirectoryServerIdentity, LastOriginatingChangeUsn, LastOriginatingChangeTime, Version, AttributeName -Wrap
# Out-GridView
Get-ADuser administrator |
 Get-ADReplicationAttributeMetadata -Server localhost |
 Select-Object LocalChangeUsn, LastOriginatingChangeDirectoryServerIdentity, LastOriginatingChangeUsn, LastOriginatingChangeTime, Version, AttributeName |
 Out-GridView
# Make several attribute updates
Get-ADUser administrator | Get-ADReplicationAttributeMetadata -Server localhost | ogv
Set-ADUser administrator -GivenName "The Big Account"
Set-ADUser administrator -GivenName "The Biggest Account"
Get-ADUser administrator | Get-ADReplicationAttributeMetadata -Server localhost | ? AttributeName -eq "givenName" | ogv
# Show all attributes that have been updated since creation
Get-ADuser administrator |
 Get-ADReplicationAttributeMetadata -Server localhost |
 Where-Object Version -GT 1 |
 Format-Table AttributeName, Version, LastOriginatingChangeTime, LastOriginatingChangeDirectoryServerIdentity -AutoSize




###############################################################################
# Show a user's group memberships and the dates they were added to those groups.

Import-Module ActiveDirectory

$username = "anlan"
$userobj  = Get-ADUser $username

Get-ADUser $userobj.DistinguishedName -Properties memberOf |
 Select-Object -ExpandProperty memberOf |
 ForEach-Object {
    Get-ADReplicationAttributeMetadata $_ -Server localhost -ShowAllLinkedValues | 
      Where-Object {$_.AttributeName -eq 'member' -and 
      $_.AttributeValue -eq $userobj.DistinguishedName} |
      Select-Object FirstOriginatingCreateTime, Object, AttributeValue
    } | Sort-Object FirstOriginatingCreateTime -Descending | Out-GridView

###############################################################################
# Here are some one-liners for exploring:
Get-ADUser 'CN=anlan,OU=Migrated,DC=CohoVineyard,DC=com' -Properties memberOf
Get-ADGroup 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' -Properties member, members, memberOf

Get-ADReplicationAttributeMetadata 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' -Server localhost -ShowAllLinkedValues | Out-GridView

# Now remove some users
$nixme = Get-ADGroupMember 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' | Sort-Object Name | Select-Object -Last 3
Remove-ADGroupMember -Identity 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' -Members $nixme -Confirm:$false

# Look at the group data again (LastOriginatingDeleteTime)
Get-ADReplicationAttributeMetadata 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' -Server localhost -ShowAllLinkedValues | Out-GridView

###############################################################################
# This works at the cmd line but not in PS console.
# However, it does not include the date data.
Repadmin.exe /showobjmeta localhost "CN=Legal,OU=Migrated,DC=CohoVineyard,DC=com" | find /i "anlan"
###############################################################################
