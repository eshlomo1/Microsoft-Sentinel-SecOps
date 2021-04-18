<##############################################################################
Ashley McGlone
Microsoft Premier Field Engineer

Function library for working with Active Directory snapshots and attribute-
level object recovery.

Prerequisites:  PowerShell v2 (v3+ required for Mount-ADSnapshot -Filter)
                Domain controller running AD Web Service (2008 R2+)
                Domain controller with remoting enabled if running remotely

dir function: | ? name -like "*ad*"

CommandType     Name
-----------     ----
Function        Dismount-ADDatabase
Function        Mount-ADDatabase   
Function        New-ADSnapshot     
Function        Remove-ADSnapshot  
Function        Repair-ADAttribute 
Function        Repair-ADUserGroup 
Function        Show-ADSnapshot    


LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.
 
This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at http://www.microsoft.com/info/cpyright.htm.
##########################################################################sdg#>


# For PSv2
Import-Module ActiveDirectory



Function New-ADSnapshot {
<#
.SYNOPSIS
   Creates a new Active Directory database snapshot.
.DESCRIPTION
   Uses NTDSUTIL to create a new Active Directory database snapshot.
   NTDSUTIL "Activate Instance NTDS" SNAPSHOT CREATE
.EXAMPLE
   New-ADSnapshot
.NOTES
   This cmdlet targets the local machine.  It must execute locally on a domain controller either through a local or remote PowerShell session.
.LINK
   http://aka.ms/GoateePFE
#>
Param()

    ntdsutil "Activate Instance NTDS" snapshot create quit quit
}



Function Mount-ADDatabase {
<#
.SYNOPSIS
   Mounts an Active Directory snapshot and the database it contains.
.DESCRIPTION
   Uses the NTDSUTIL SNAPSHOT MOUNT command to mount the snapshot.
   Uses DSAMAIN.EXE to mount the database contained in the snapshot.
   Parameters define which snapshot and port to use.
.PARAMETER LDAPPort
   Port for DSAMAIN to advertise the database.
   Must be in the range 1025 to 65535.
   Checks to make sure another database is not already using the port.
   The other ports use (SSL) LDAP+1, (GC) LDAP+2, and (GC-SSL) LDAP+3.
   For more information on DSAMAIN see the TechNet link in the Links portion of this help topic.
.PARAMETER Filter
   Prompts the user for which snapshot to mount.
   Does not work over a remote session.
   Requires PowerShell v3 or above.
.PARAMETER First
   Automatically mounts the first (oldest) snapshot.
.PARAMETER Last
   Automatically mounts the last (newest) snapshot.
.EXAMPLE
   Mount-ADDatabase -Filter -LDAPPort 33389
.EXAMPLE
   Mount-ADDatabase -First -LDAPPort 33389
.EXAMPLE
   Mount-ADDatabase -Last -LDAPPort 33389
.NOTES
   This cmdlet will launch the DSAMAIN process in a separate window.  This window must remain open throughout the snapshot usage.  To close it use the cmdlet Dismount-ADDatabase.
.LINK
   http://aka.ms/GoateePFE
.LINK
   http://technet.microsoft.com/en-us/library/cc772168(v=ws.10).aspx
#>
Param (
    [parameter(Mandatory=$true)]
    [ValidateScript({
        # Must specify an LDAP port not in use
        $x = $null
        Try {$x = Get-ADRootDSE -Server localhost:$_}
        Catch {$null}
        If ($x) {$false} Else {$true}
    })]
    [ValidateRange(1025,65535)]
    [int]
    $LDAPPort,
    [parameter(Mandatory=$true,
               ParameterSetName="Filter")]
    [ValidateScript({$Host.Name -ne 'ServerRemoteHost'})]
    [switch]$Filter,
    [parameter(Mandatory=$true,
               ParameterSetName="First")]
    [switch]$First,
    [parameter(Mandatory=$true,
               ParameterSetName="Last")]
    [switch]$Last
)
    # Parse snapshot list
    $snaps = ntdsutil snapshot "list all" quit quit
    If ($First) {
        # Pick the first snapshot in the list
        # Use @() in case a single row comes back for PSv2
        $ChoiceNumber = (@(($snaps | Select-String -SimpleMatch '/'))[0] -split ':')[0].Trim()
    } ElseIf ($Last) {
        # Pick the last snapshot in the list
        # Use @() in case a single row comes back for PSv2
        $ChoiceNumber = (@(($snaps | Select-String -SimpleMatch '/'))[-1] -split ':')[0].Trim()
    } Else {
        $Choice = $snaps | Select-String -SimpleMatch '/' |
            Select-Object -ExpandProperty Line |
            Out-GridView -Title 'Select the snapshot to mount' -OutputMode Single
        If ($Choice -eq $null) {
            # What if the user hits the Cancel button in the OGV?
            Exit
        } Else {
            $ChoiceNumber = ($Choice -split ':')[0].Trim()
        }
    }

    # Mount Snapshot
    $Mount = ntdsutil snapshot "list all" "mount $ChoiceNumber" quit quit
    # If already mounted, will return "Snapshot {1753bd1a-7905-4e2b-a976-254198a3fe3e} is already mounted."
    $MountPath = (($Mount | Select-String -SimpleMatch 'mounted as') -split 'mounted as')[-1].Trim()
    $DITPath = (Get-Item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Database File").SubString(2)
    $NTDSdit = Join-Path -Path $MountPath -ChildPath $DITPath

    # Mounted snapshots show up in the ExposedName column
    $MountedWMI  = Get-WmiObject Win32_ShadowCopy | Select-Object Id, Installdate, OriginatingMachine, ClientAccessible, NoWriters, ExposedName
    $MountedNTDS = ntdsutil snapshot "list mounted" quit quit

    # Mount the database in the snapshot
    # Start in its own process, because it must continue to run in the background.
    Write-Host 'Mounting database: .' -NoNewline
    $DSAMAIN = Start-Process -FilePath dsamain.exe -ArgumentList "-dbpath $NTDSdit -ldapport $LDAPPort" -PassThru

    # Wait for database mount to complete
    # Get-ADRootDSE does not seem to obey the ErrorAction parameter
    $ErrorActionPreference = 'SilentlyContinue'
    $d = $null
    Do {
        $d = Get-ADRootDSE -Server localhost:$LDAPPort
        Start-Sleep -Seconds 1
        Write-Host '.' -NoNewline
    }
    Until ($d)
    Write-Host '.'
    $ErrorActionPreference = 'Continue'

    If ($Verbose) {
        $MountedWMI | Format-Table Id, Installdate, OriginatingMachine, ClientAccessible, NoWriters, ExposedName -AutoSize
        $MountedNTDS
        $DSAMAIN
    }
}



Function Dismount-ADDatabase {
<#
.SYNOPSIS
   Dismounts the Active Directory database and the snapshot that contained it.
.DESCRIPTION
   Uses NTDSUTIL to dismount the Active Directory database and the snapshot that contained it.
   This is a two-step process:
   1. Stop the DSAMAIN instance of the database.
   2. Unmount the snapshot using NTDSUTIL SNAPSHOT UNMOUNT.
.EXAMPLE
   Dismount-ADDatabase
.NOTES
   This cmdlet will dismount all currently-mounted Active Directory database snapshots.
.LINK
   http://aka.ms/GoateePFE
#>
Param()
    # Dismount the database
    Get-Process dsamain -ErrorAction SilentlyContinue | Stop-Process

    # Unmount snapshot
    # $ChoiceNumber no longer cooresponds here, because the list is different
    ntdsutil snapshot "list mounted" "unmount *" quit quit

}



Function Show-ADSnapshot {
<#
.SYNOPSIS
   Lists the snapshots available on the Active Directory domain controller.
.DESCRIPTION
   Lists the snapshots using one of two methods:
   1. (Default) NTDSUTIL SNAPSHOT LIST ALL
   2. Get-WMIObject Win32_ShadowCopy
.PARAMETER WMI
   Switch to display output from WMI instead of NTDSUTIL.
.EXAMPLE
   Show-ADSnapshot
.EXAMPLE
   Show-ADSnapshot -WMI
.NOTES
   Either view will designate snapshots that are already mounted.
   The WMI version will show VolumeShadow backups outside of NTDSUTIL SNAPSHOT as ClientAccessible=True.
   These are reported as FYI and out-of-scope for NTDSUTIL Active Directory snapshots.
.LINK
   http://aka.ms/GoateePFE
#>
Param (
    [switch]$WMI
)
    If ($WMI) {
        Get-WmiObject Win32_ShadowCopy | Select-Object Id,  @{name='Install_Date';expression={$_.ConvertToDateTime($_.InstallDate)}}, OriginatingMachine, ClientAccessible, NoWriters, ExposedName | Sort-Object Install_Date
    } Else {
        ntdsutil snapshot "list all" quit quit
    }
}



Function Remove-ADSnapshot {
<#
.SYNOPSIS
   Deletes local Active Directory database snapshots.
.DESCRIPTION
   Uses NTDSUTIL to delete local Active Directory database snapshots.
   NTDSUTIL SNAPSHOT DELETE
.PARAMETER All
   Delete all snapshots.
.PARAMETER Keep
   Specify a number of snapshots to keep and delete the remainder.
.PARAMETER First
   Keeps the first (oldest) snapshots.
.PARAMETER Last
   Keeps the last (newest) snapshots.
.EXAMPLE
   Remove-ADSnapshot -Keep 5 -First
.EXAMPLE
   Remove-ADSnapshot -Keep 5 -Last
.EXAMPLE
   Remove-ADSnapshot -All
.NOTES
   If Active Directory snapshots are scheduled on a regular basis according to best practice, then they must also be pruned to prevent disk space issues.
   Run this cmdlet before or after New-ADSnapshot to remove older snapshots.
.LINK
   http://aka.ms/GoateePFE
#>
Param(
    [parameter(Mandatory=$true,
               ParameterSetName="All")]
    [switch]$All,
    [parameter(Mandatory=$true,
               ParameterSetName="First")]
    [parameter(Mandatory=$true,
               ParameterSetName="Last")]
    [int]$Keep,
    [parameter(Mandatory=$true,
               ParameterSetName="First")]
    [switch]$First,
    [parameter(Mandatory=$true,
               ParameterSetName="Last")]
    [switch]$Last
)

    If ($All) {
        ntdsutil snapshot "list all" "delete *" quit quit
    } Else {
        # Decide which array index to delete, first or last.
        # If keeping first x, then trim last.
        # If keeping last x,  then trim first.
        $snaps = ntdsutil snapshot "list all" quit quit
        $snapsArray = @(($snaps | Select-String -SimpleMatch '/'))
        If ($snapsArray.Count -gt $Keep) {
            If ($First) {$DeleteMe = -1} Else {$DeleteMe = 0}
            While ($snapsArray.count -gt $Keep) {
                $ChoiceNumber = ($snapsArray[$DeleteMe] -split ':')[0].Trim()
                ntdsutil snapshot "list all" "delete $ChoiceNumber" quit quit
                $snaps = ntdsutil snapshot "list all" quit quit
                $snapsArray = @(($snaps | Select-String -SimpleMatch '/'))
            }
        } Else {
            "No snapshots to delete in that range."
        }
    }

}



Function Repair-ADAttribute {
<#
.SYNOPSIS
   Copies one or more object attributes from the database snapshot version into the same attribute in the live copy of the Active Directory database.
.DESCRIPTION
   Effectively this cmdlet does an attribute-level restore for an object by rewriting the old values over the new values.
.PARAMETER Property
   One or more Active Directory attribute names delimited by commas.
   The attribute name must be valid and must be writable.
   Supports single-value and multi-value attributes.
.PARAMETER ObjectGUID
   ObjectGUID of the Active Directory object for attribute recovery.
   It is preferred to pipe this from another cmdlet (Get-ADUser, Get-ADObject, etc.).
   This parameter accepts pipeline input and can run against multiple objects.
   ObjectGUID is used instead of DistinguishedName in case the object path has changed since the snapshot.
.PARAMETER LDAPPort
   Must be the LDAPPort of a previously-mounted database snapshot.
   Must be in the range 1025 to 65535.
.EXAMPLE
   Get-ADUser Guest | Repair-ADAttribute -Property Description -LDAPPort 33389
.EXAMPLE
   Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property Department,Description -LDAPPort 33389
.EXAMPLE
   Get-ADUser -filter {name -like "*bad_data*"} | Repair-ADAttribute -Property Department,Description -LDAPPort 33389
.EXAMPLE
   Get-ADUser -filter {name -like "*good_data*"} -Server Localhost:33389 | Repair-ADAttribute -Property Department,Description -LDAPPort 33389
.EXAMPLE
   Get-ADComputer Server1 | Repair-ADAttribute -Property ServicePrincipalName -LDAPPort 33389
.EXAMPLE
   Get-ADComputer -Filter * | Repair-ADAttribute -Property Description,ServicePrincipalName -LDAPPort 33389
.EXAMPLE
   Get-ADGroup "Domain Admins" | Repair-ADAttribute -Property member -LDAPPort 33389
.INPUTS
   Active Directory object(s) containing the ObjectGUID attribute.
.OUTPUTS
   PowerShell custom object for logging with these properties:
     ObjGUID   : ObjectGUID attribute of the object for repair
     NewObject : DistinguishedName of the object located in the current database
     OldObject : DistinguishedName of the object located in the snapshot database
     NewValue  : Value of the property in the current database
     OldValue  : Value of the property in the snapshot database
     Property  : AD attribute name for repair
     Action    : Describes the repair action taken: Added, Removed, Replaced, Not Found
     Moved     : Is the DistinguishedName of the two object copies different? IE. Was it moved or renamed between the snapshot and current?
.NOTES
   This cmdlet compares snapshot (old) and current (new) values for the specified property or properties.  There are four possible outcomes:
   1.  Values are equal.  No change.
   2.  Values are not equal.  Change the current value to match the snapshot value.
   3.  Snapshot object is not found in current database.  No change.
   4.  Current object is not found in snapshot database.  No change.
   Items number 3 and 4 may occur if the object has been deleted or created since the snapshot.

   When you pipe to this cmdlet the source of objects will come from either the snapshot or the current database.  There are multiple ways to use it.  Here are some examples:
   -Get corrupted objects from the current database.  Filter on the known bad data.  Pipe to this cmdlet.
   -Get known good objects from the snapshot database.  Filter on the known good data.  Pipe to this cmdlet.
.LINK
   http://aka.ms/GoateePFE
#>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [parameter(Mandatory=$true)]
    [String[]]
    $Property,
    [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String]
    $ObjectGUID,
    [parameter(Mandatory=$true)]
    [ValidateScript({
        # Must specify an LDAP snapshot port in use
        $x = $null
        Try {$x = Get-ADRootDSE -Server localhost:$_}
        Catch {$null}
        If ($x) {$true} Else {$false}
    })]
    [ValidateRange(1025,65535)]
    [int]
    $LDAPPort
)

Begin {}

Process {
    # Query the mounted database snapshot
    # Compare old and current values for property
    # Possible outcomes:
    #  -match
    #  -notmatch
    #  -object no longer exists in snapshot (Object piped in from current)
    #  -object no longer exists in current  (Object piped in from snapshot query)

    # User ObjectGUID to locate the objects, because the DistinguishedName path
    # could change by the object being moved, renamed, or deleted.
    $Identity  = $_.ObjectGUID
    
    # We don't know where the object is piped from (snaphot or current).
    # We cannot guarantee that it exists in both places.
    # Does the object exist in both the snapshot and the current directory?
    # OLD
    try   { $OldObject = Get-ADObject -Identity $Identity -Properties $Property -Server localhost:$LDAPPort }
    catch { $OldObject = $null }
    # NEW
    try   { $NewObject = Get-ADObject -Identity $Identity -Properties $Property -Server localhost }
    catch { $NewObject = $null }


    If (($OldObject -eq $null) -or ($NewObject -eq $null)) {
        
        # Which database is missing the object?
        # If both, then default to reporting only Current (bad input, rare).
        If ($OldObject) {$Database = 'Current'} Else {$Database = 'Snapshot'}
        
        # Old object not present in new database
        New-Object -TypeName PSObject -Property @{
            ObjGUID   = $Identity
            OldObject = $OldObject.DistinguishedName
            NewObject = $NewObject.DistinguishedName
            Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
            Property  = $null
            OldValue  = $null
            NewValue  = $null
            Action    = "Not Found in $Database"
        }

    } Else {

        # Found in both databases

        # Loop through each property in the list
        ForEach ($PropertyEach in $Property) {
    
            # Get the old property value
            try {
                # If the property value returns null, then Select-Object -ExpandProperty errors.
                # Select-Object does not seem to obey when you specify -ErrorAction SilentlyContinue.
                $OldValue = $null = $OldObject | Select-Object -ExpandProperty $PropertyEach
                #$OldValue = $OldObject.Item($PropertyEach)
            } catch {
                $OldValue = $null
            }

            try {
                # If the property value returns null, then Select-Object -ExpandProperty errors.
                # Select-Object does not seem to obey when you specify -ErrorAction SilentlyContinue.
                $NewValue = $null = $NewObject | Select-Object -ExpandProperty $PropertyEach
                #$NewValue = $NewObject.Item($PropertyEach)
            } catch {
                $NewValue = $null
            }


            If ($OldValue -eq $NewValue) {

                # Matching values
                # PSv2 New-Object for compatibility instead of [PSCustomObject] in v3+
                New-Object -TypeName PSObject -Property @{
                    ObjGUID   = $Identity
                    OldObject = $OldObject.DistinguishedName
                    NewObject = $NewObject.DistinguishedName
                    Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
                    Property  = $PropertyEach
                    OldValue  = $OldValue
                    NewValue  = $NewValue
                    Action    = 'No Change'
                }
            
            } Else {
            
                # Is this a multi-value attribute?
                $PropertyDefinition = $OldObject | Get-Member -MemberType Property | Where-Object {$_.Name -eq $PropertyEach} | Select-Object -ExpandProperty Definition
                If ($PropertyDefinition -like "*Microsoft.ActiveDirectory.Management.ADPropertyValueCollection*") {

                    # MULTI-VALUE
                    # Do a proper true-up of individual multi-values.
                    # Multivalue attributes cannot be directly compared as whole values, 
                    # because the individual values are listed in different orders,
                    # making the two object properties always look different.
                    # If either of the values are NULL, then Compare-Object will error.
                    # If there are values on both sides and it is multivalue, then we want to surgically add/remove the respective individual values.
                    # For example, this can become a big deal when working with groups containing 1000s of users.  We don't want to rebuild the entire group membership.

                    If ($OldValue -eq $null) {
                        $ToRemove = $NewValue
                    } ElseIf ($NewValue -eq $null) {
                        $ToAdd    = $OldValue
                    } Else {
                        $Compare  = Compare-Object -ReferenceObject $OldValue -DifferenceObject $NewValue
                        $ToRemove = $Compare | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object -ExpandProperty InputObject
                        $ToAdd    = $Compare | Where-Object {$_.SideIndicator -eq '<='} | Select-Object -ExpandProperty InputObject
                    }

                
                    If ($ToRemove -or $ToAdd) {

                        If ($ToRemove) { # If block added for PSv2 compatibility.

                            # Remove new values that were added
                            ForEach ($Value in $ToRemove) {
                                Set-ADObject -Identity $Identity -Remove @{$PropertyEach="$Value"}
                                New-Object -TypeName PSObject -Property @{
                                    ObjGUID   = $Identity
                                    OldObject = $OldObject.DistinguishedName
                                    NewObject = $NewObject.DistinguishedName
                                    Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
                                    Property  = $PropertyEach
                                    OldValue  = $null
                                    NewValue  = $Value
                                    Action    = 'Removed'
                                }
                            }
                        }
                        
                        If ($ToAdd) {  # If block added for PSv2 compatibility.

                            # Add back old values that were deleted
                            ForEach ($Value in $ToAdd) {
                                Set-ADObject -Identity $Identity -Add @{$PropertyEach="$Value"}
                                New-Object -TypeName PSObject -Property @{
                                    ObjGUID   = $Identity
                                    OldObject = $OldObject.DistinguishedName
                                    NewObject = $NewObject.DistinguishedName
                                    Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
                                    Property  = $PropertyEach
                                    OldValue  = $Value
                                    NewValue  = $null
                                    Action    = 'Added'
                                }
                            }
                    
                        }

                    } Else {
                
                        # Nothing to remove or add, so the two lists match.
                        # This is an equal multi-value property comparison.
                        # It is possible the multi-value property contents were already matched earlier
                        # in the logic if the data in each attribute was listed in the same order.
                        New-Object -TypeName PSObject -Property @{
                            ObjGUID   = $Identity
                            OldObject = $OldObject.DistinguishedName
                            NewObject = $NewObject.DistinguishedName
                            Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
                            Property  = $PropertyEach
                            OldValue  = $OldValue
                            NewValue  = $NewValue
                            Action    = 'No Change'
                        }                
                
                    }


                } Else {

                    # Different values
                    If ($OldValue -eq $null) {
                        # -Replace cannot set a null value. Must use -Clear in that case.
                        #Set-ADObject -Server localhost -Identity $NewObject -Clear $PropertyEach
                        Set-ADObject -Server localhost -Identity $Identity -Clear $PropertyEach
                    } Else {
                        # This one line is the heart of the script.
                        # If only it all could have been this easy!  :-)
                        #Set-ADObject -Server localhost -Identity $NewObject -Replace @{$PropertyEach=$OldValue}
                        Set-ADObject -Server localhost -Identity $Identity -Replace @{"$PropertyEach"="$OldValue"}
                    }

                    New-Object -TypeName PSObject -Property @{
                        ObjGUID   = $Identity
                        OldObject = $OldObject.DistinguishedName
                        NewObject = $NewObject.DistinguishedName
                        Moved     = ($OldObject.DistinguishedName -ne $NewObject.DistinguishedName)
                        Property  = $PropertyEach
                        OldValue  = $OldValue
                        NewValue  = $NewValue
                        Action    = 'Replaced'
                    }

                } # End If Multi-value

            } # End If Old Equals New

        } # End ForEach

    } # End If

} # End Process

End {}

}



Function Repair-ADUserGroup {
<#
.SYNOPSIS
   Rewrites the MemberOf computed backlinks for a user's group memberships.
.DESCRIPTION
   Puts the user back into the groups where they were in the snapshot copy of the database.
.PARAMETER DistinguishedName
   DistinguishedName of the user to repair group membership.
.PARAMETER LDAPPort
   Must be the LDAPPort of a previously-mounted database snapshot.
   Must be in the range 1025 to 65535.
.EXAMPLE
   Get-ADUser Guest | Repair-ADUserGroup -LDAPPort 33389 -WhatIf
.EXAMPLE
   Get-ADUser Guest | Repair-ADUserGroup -LDAPPort 33389
.EXAMPLE
   Get-ADUser Guest | Repair-ADUserGroup -LDAPPort 33389 -Confirm:$False
.EXAMPLE
   Get-ADUser -Filter {Name -like "B*"} | Repair-ADUserGroup -LDAPPort 33389
.INPUTS
   It is preferred to query for a user or users and pipe them into the cmdlet.
.NOTES
   The MemberOf attribute is computed, and it is not an editable attribute.  In order to repair group memberships the user must be added or removed directly on each group object.
   This only works on groups in the same domain.  If you want to modify the code, then you must target a GC for Domain Local and other domain groups.  Then you must figure out the authentication to those other DCs.  You will need to adjust the -Server connection ports to hit GC 3268 and snapshot port +2 for snapshot GC port.
.LINK
   http://aka.ms/GoateePFE
#>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String]
    $DistinguishedName,
    [parameter(Mandatory=$true)]
    [ValidateScript({
        # Must specify an LDAP snapshot port in use
        $x = $null
        Try {$x = Get-ADRootDSE -Server localhost:$_}
        Catch {$null}
        If ($x) {$true} Else {$false}
    })]
    [ValidateRange(1025,65535)]
    [int]
    $LDAPPort
)

    Begin {}

    Process {
        $OldGroups = Get-ADUser $_ -Properties memberOf -Server localhost:$LDAPPort | Select-Object -ExpandProperty MemberOf
        $NewGroups = Get-ADUser $_ -Properties memberOf -Server localhost | Select-Object -ExpandProperty MemberOf

        If ($OldGroups -eq $null) {
            $GroupsToRemove = $NewValue
        } ElseIf ($NewGroups -eq $null) {
            $GroupsToAdd    = $OldValue
        } Else {
            $Compare   = Compare-Object -ReferenceObject $OldGroups -DifferenceObject $NewGroups
            $GroupsToRemove = $Compare | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object -ExpandProperty InputObject
            $GroupsToAdd    = $Compare | Where-Object {$_.SideIndicator -eq '<='} | Select-Object -ExpandProperty InputObject
        }

        If ($GroupsToRemove) { # If block added for PSv2 compatibility.
            ForEach ($Group in $GroupsToRemove) {
                Remove-ADGroupMember -Identity $Group -Members $_
                New-Object -TypeName PSObject -Property @{
                    Identity = $_
                    Group    = $Group
                    Action   = 'Removed'
                }
            }
        }

        If ($GroupsToAdd) { # If block added for PSv2 compatibility.
            ForEach ($Group in $GroupsToAdd) {
                Add-ADGroupMember -Identity $Group -Members $_
                New-Object -TypeName PSObject -Property @{
                    Identity = $_
                    Group    = $Group
                    Action   = 'Added'
                }
            }
        }

    }

    End {}

}

