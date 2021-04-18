break

<#
http://technet.microsoft.com/en-us/library/hh831702.aspx

Create a user, group, OU
Put the user in the group in the OU
Delete the OU recursively
Restore the OU recursively
Verify that the memberships are all in tact
#>


# Raise functional level to 2008 R2 or higher
Set-ADForestMode –Identity cohovineyard.com -ForestMode Windows2008R2Forest –Confirm:$false
(Get-ADForest).ForestMode

# Enable AD Recycle Bin.  The warning is normal.
# You'll see an error if it is already enabled.
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet `
    -Target (Get-ADForest).RootDomain -server (Get-ADForest).DomainNamingMaster `
    -Confirm:$false

# Accidental deletions are the #1 cause of AD restores.
# The AD Recycle Bin reduces recovery from hours to minutes.
Get-ADUser alsimmon | Set-ADUser -Description "Please do not delete me   :-)"

#   In ADUC go to the OU "Sales".
#***Manually delete the user alsimmon "Please don't delete me.".
#   We could do this from script, but the GUI is impressive for the demo.
Remove-ADUser alsimmon -Confirm:$false

# List deleted objects.  Notice:
#   -IncludeDeletedObjects
#   -SearchBase (Get-ADDomain).DeletedObjectsContainer
#   -LDAPFilter '(!name=Deleted Objects)'
Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter '(!name=Deleted Objects)' -Property * -IncludeDeletedObjects | 
    Where-Object {$_.samAccountName -eq 'alsimmon'} |
    Format-Table objectClass, SamAccountName, msDS-LastKnownRDN, LastKnownParent -AutoSize

# Enumerate object(s) and prompt for restore (y/n)
Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter '(!name=Deleted Objects)' -Property * -IncludeDeletedObjects | 
    Where-Object {$_.samAccountName -eq 'alsimmon'} |
    Restore-ADObject -Confirm

# In ADUC go to the OU "Sales" and refresh to show the user has returned.
Get-ADUser alsimmon



# RECYCLE BIN GUI
#   Launch ADAC
#   Navigate to: \domain\Deleted Objects\
#   Use the filter at top to find your object




### Recursive restore for OU and contents.
### Requires some custom code to restore in parent/child order.
### You can find scripts for this online.


# Manually delete the OU "Legal" from the AD Users & Computers GUI.
# When prompted check the box for delete subtree and click Yes.
# We could do this from script, but the GUI is impressive for the demo.

# List deleted objects and whether their parent container exists
Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter "(!name=Deleted Objects)" -Property * -IncludeDeletedObjects | 
    Select-Object objectClass, msDS-LastKnownRDN, @{name="ParentExists";expression={Test-Path "AD:$($_.LastKnownParent)"}}, LastKnownParent | 
    Sort-Object objectClass, msDS-LastKnownRDN | 
    Format-Table * -AutoSize

# Recursively restore the OU and all contents.
# When prompted, enter "y" for both the OU and its children.
# Select the text of the next to functions and the calling line afterward, then press F8 in the ISE.
Function RestoreChildren ($ParentDN) {
    #Query for OU child objects and subtree restore them
    $RestoredOUChildren = Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter "(!name=Deleted Objects)" -Property ObjectGUID, ObjectClass, LastKnownParent, DistinguishedName -IncludeDeletedObjects | Where-Object {$_.LastKnownParent -eq $ParentDN}
    #Only proceed if there were children involved
    If ($RestoredOUChildren) {
        ForEach ($child in $RestoredOUChildren) {
            $ChildLastParent = $child.DistinguishedName.Substring(0,$child.DistinguishedName.IndexOf("\"))+","+$child.LastKnownParent
            Restore-ADObject $child.DistinguishedName
            If ($child.ObjectClass -eq "OrganizationalUnit") {
                RestoreChildren $ChildLastParent
            } #end If
        } #end ForEach
    } #end If
} #end Function

Function Restore-ADOrganizationalUnit {
    #Get all deleted OUs
    $DeletedOUs = Get-ADObject -SearchBase (Get-ADDomain).DeletedObjectsContainer -LDAPFilter "(&(!name=Deleted Objects)(objectClass=OrganizationalUnit))" -Property * -IncludeDeletedObjects | Select-Object objectClass, msDS-LastKnownRDN, LastKnownParent, @{name="ParentExists";expression={Test-Path "AD:$($_.LastKnownParent)"}}, DistinguishedName, ObjectGUID
    #For each one with a valid parent (ie. not orphaned child OUs) prompt to restore.
    $DeletedOUs | Where-Object {$_.ParentExists} | ForEach-Object {
        $a = Read-Host "$($_.DistinguishedName)`rDo you want to restore this OU (y/n)?"
        If ($a -eq "y") {
            #Reconstruct the parent's original distinguishedName
            $ChildLastParent = $_.DistinguishedName.Substring(0,$_.DistinguishedName.IndexOf("\"))+","+$_.LastKnownParent
            Restore-ADObject $_.DistinguishedName
            #Prompt to restore child objects.
            $b = Read-Host "$($_.DistinguishedName)`rDo you want to restore this OU's child objects (y/n)?"
            If ($b -eq "y") {
                #As soon as the restore happened above, all of the former children's
                #LastKnownParent attributes were updated to the good distinguishedName
                #from the one with DEL <GUID> in it.
                RestoreChildren $ChildLastParent
            } #end If
        } #end If
    } #end ForEach-Object
} #end Function

Restore-ADOrganizationalUnit

# In ADUC refresh to show the OU and all contents have returned.
Remove-ADOrganizationalUnit (Get-ADOrganizationalUnit Newusers)