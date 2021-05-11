break

###############################################################################
# GET PERMISSIONS
###############################################################################

# DSACLS
DSACLS "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local"

# nTSecurityDescriptor property
$ou  = "OU=Newusers,DC=cohovineyard,DC=com"
(Get-ADObject $ou -Property nTSecurityDescriptor |
  Select-Object -ExpandProperty nTSecurityDescriptor).Access

# Get-ACL
Get-ACL "AD:\$ou"
(Get-ACL "AD:\$ou") | fl AccessToString, Access, Sddl
(Get-ACL "AD:\$ou").Access | Out-Gridview


###############################################################################
# SET PERMISSIONS
###############################################################################

# DSACLS
# ---Note that in PowerShell we have to escape the semicolons (;)
# Full control to the OU and all child objects
DSACLS "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local" /I:T /G wingtiptoys\anlan:GA`;`;
# Full control to user objects
DSACLS "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local" /I:S /G wingtiptoys\anlan:GA`;`;user
# Remove permissions for this user
DSACLS "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local" /R wingtiptoys\anlan

# Set-ACL
# Full control to the OU and all child objects
$ou  = "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local"
$acl = Get-ACL "AD:\$ou"
$sid = (Get-ADUser anlan -Properties objectSID).objectSID
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $sid,"GenericAll","Allow","All"
$acl.AddAccessRule($ace)
Set-ACL "AD:\$ou" -AclObject $acl

# Full control to descendent user objects
$ou  = "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local"
$acl = Get-ACL "AD:\$ou"
$sid = (Get-ADUser anlan -Properties objectSID).objectSID
$UserGuid = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $sid,"GenericAll","Allow","Descendents",$UserGuid
$acl.AddAccessRule($ace)
Set-ACL "AD:\$ou" -AclObject $acl

# Special permissions to all user objects
$ou  = "OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local"
$acl = Get-ACL "AD:\$ou"
$sid = (Get-ADUser anlan -Properties objectSID).objectSID
$UserGuid = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $sid,"CreateChild, Self, WriteProperty, ExtendedRight, Delete, GenericRead, WriteDacl, WriteOwner","Allow","All",$UserGuid
$acl.AddAccessRule($ace)
Set-ACL "AD:\$ou" -AclObject $acl

# Remove permissions
$acl.RemoveAccess($sid,"allow")
Set-ACL "AD:\$ou" -AclObject $acl

# Get the ACE for a specific user on a specific OU
(Get-ACL "AD:\OU=Manufacturing,OU=Production,DC=wingtiptoys,DC=local").Access |
 Where-Object {$_.IdentityReference -eq "WINGTIPTOYS\anlan"}

###############################################################################
# Reference
###############################################################################

[Enum]::GetValues("System.Security.AccessControl.AccessControlType")
[Enum]::GetValues("System.DirectoryServices.ActiveDirectoryRights")
[Enum]::GetValues("System.DirectoryServices.ActiveDirectorySecurityInheritance")

<#
A couple related blog posts:
http://blogs.msdn.com/b/adpowershell/archive/2009/09/22/how-to-find-extended-rights-that-apply-to-a-schema-class-object.aspx
http://blogs.technet.com/b/heyscriptingguy/archive/2012/03/12/use-powershell-to-explore-active-directory-security.aspx

See the following MSDN links documenting these objects and enumerations:
http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectoryaccessrule.aspx
http://msdn.microsoft.com/en-us/library/99s25ayd.aspx
http://msdn.microsoft.com/en-us/library/99s25ayd.aspx
http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectoryrights.aspx
http://msdn.microsoft.com/en-us/library/w4ds5h86.aspx
http://msdn.microsoft.com/en-us/library/4b75624d.aspx
http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectorysecurityinheritance.aspx
http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectorysecurity.aspx
http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectorysecurity.removeaccess.aspx
#>

###############################################################################


Get-ADOrganizationalUnit -filter * -Properties nTSecurityDescriptor |
     Select-Object DistinguishedName, @{name='Owner';Expression={$_.nTSecurityDescriptor.Owner}}



##############################################################################>

Import-Module ActiveDirectory

# This array will hold the report output.
$report = @()

# Build a lookup hash table that holds all of the string names of the
# ObjectType GUIDs referenced in the security descriptors.
# See the Active Directory Technical Specifications:
#  3.1.1.2.3 Attributes
#    http://msdn.microsoft.com/en-us/library/cc223202.aspx
#  3.1.1.2.3.3 Property Set
#    http://msdn.microsoft.com/en-us/library/cc223204.aspx
#  5.1.3.2.1 Control Access Rights
#    http://msdn.microsoft.com/en-us/library/cc223512.aspx
#  Working with GUID arrays
#    http://blogs.msdn.com/b/adpowershell/archive/2009/09/22/how-to-find-extended-rights-that-apply-to-a-schema-class-object.aspx
# Hide the errors for a couple duplicate hash table keys.
$schemaIDGUID = @{}
### NEED TO RECONCILE THE CONFLICTS ###
$ErrorActionPreference = 'SilentlyContinue'
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
$ErrorActionPreference = 'Continue'

# Get a list of all OUs.  Add in the root containers for good measure (users, computers, etc.).
$OUs  = @(Get-ADDomain | Select-Object -ExpandProperty DistinguishedName)
$OUs += Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
$OUs += Get-ADObject -SearchBase (Get-ADDomain).DistinguishedName -SearchScope OneLevel -LDAPFilter '(objectClass=container)' | Select-Object -ExpandProperty DistinguishedName

# Loop through each of the OUs and retrieve their permissions.
# Add report columns to contain the OU path and string names of the ObjectTypes.
ForEach ($OU in $OUs) {
    $report += Get-Acl -Path "AD:\$OU" |
     Select-Object -ExpandProperty Access | 
     Select-Object @{name='organizationalUnit';expression={$OU}}, `
                   @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                   @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                   *
}

# Dump the raw report out to a CSV file for analysis in Excel.
$report | Export-Csv -Path ".\OU_Permissions.csv" -NoTypeInformation
Start-Process ".\OU_Permissions.csv"

###############################################################################
# Various reports of interest
###############################################################################
break

# Show only explicitly assigned permissions by Group and OU
$report |
 Where-Object {-not $_.IsInherited} |
 Select-Object IdentityReference, OrganizationalUnit -Unique |
 Sort-Object IdentityReference | ogv

# Show explicitly assigned permissions for a user or group
$filter = Read-Host "Enter the user or group name to search in OU permissions"
$report |
 Where-Object {$_.IdentityReference -like "*$filter*"} |
 Select-Object IdentityReference, objectTypeName, OrganizationalUnit, IsInherited -Unique |
 Sort-Object IdentityReference

##############################################################################>
$report | ogv


# Import permissions from CSV and apply to OUs


$CSV = Import-Csv .\OU_Permissions.csv | Where-Object {$_.IsInherited -eq "FALSE"}

ForEach ($row in $CSV) {

    $acl = Get-ACL "AD:\$($row.organizationalUnit)"
    $account = New-Object System.Security.Principal.NTAccount($($row.IdentityReference))
    $sid = $account.Translate([System.Security.Principal.SecurityIdentifier])
    $ObjectType = [GUID]$($row.ObjectType)
    $InheritedObjectType = [GUID]$($row.InheritedObjectType)
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
        $sid, $row.ActiveDirectoryRights, $row.AccessControlType, $ObjectType, `
        $row.InheritanceType, $InheritedObjectType
    $acl.AddAccessRule($ace)
    Set-ACL "AD:\$ou" -AclObject $acl

}
