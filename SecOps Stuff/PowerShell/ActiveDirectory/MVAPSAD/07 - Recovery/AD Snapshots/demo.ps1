<##############################################################################
Ashley McGlone
Microsoft Premier Field Engineer

Function library for working with Active Directory snapshots and attribute-
level object recovery.

Prerequisites:  PowerShell v2 (v3+ required for Mount-ADSnapshot -Filter)
                Domain controller running AD Web Service (2008 R2+)
                Domain controller with remoting enabled if running remotely

dir Function: | Where-Object {$_.Name -like "*-ad*"}

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


Set-Location 'C:\Users\administrator.COHOVINEYARD\Documents\MVA\07 - Recovery\AD Snapshots'
. .\AD_Snapshot_Functions.ps1
Set-Location C:\
dir Function: | Where-Object {$_.Name -like "*-ad*"}

# Don't run this whole script by accident.
# Demo one line at a time.
break


#----Basic functionality demo----

New-ADSnapshot

Show-ADSnapshot | ogv

Show-ADSnapshot -WMI | ogv

help Mount-ADDatabase

Mount-ADDatabase -Last -LDAPPort 33389

# Notice the snapshot list now shows which one is mounted
Show-ADSnapshot | ogv
Show-ADSnapshot -WMI | ogv

Get-ADUser Guest -Properties Description -Server localhost:33389
Get-ADUser Guest -Properties Description -Server localhost

# Corrupt, then repair a single attribute for a single account
Get-ADUser Guest | Set-ADObject -Replace @{Description="foo"}
Get-ADUser Guest -Server localhost | Repair-ADAttribute -Property Description -LDAPPort 33389


# Repair multiple attributes for multiple accounts

# Corrupt some descriptions
Get-ADUser -filter {name -like "G*"} | Set-ADObject -Replace @{Description="foo"}
# Delete one of the test accounts
Get-ADUser -filter {name -like "G*"} | Select-Object -First 1 | Remove-ADObject -Confirm:$false
# Create a new account in the current database
New-ADUser -Name Goofy
# View the current objects
Get-ADUser -filter {name -like "G*"} -Properties Department,Description
# View the snapshot objects
Get-ADUser -filter {name -like "G*"} -Properties Department,Description -Server localhost:33389
# Run a -WhatIf to see where the damage is
Get-ADUser -filter {name -like "G*"} -Server localhost | Repair-ADAttribute -Property Department,Description -LDAPPort 33389 -WhatIf | ogv
# Run the actual repair
Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property Department,Description -LDAPPort 33389
# View the corrected objects
Get-ADUser -filter {name -like "G*"} -Properties Department,Description

# Reset
# Error for GOOFY account
Get-ADObject -Filter {name -like "G*"} -IncludeDeletedObjects -SearchBase 'CN=Deleted Objects,DC=CohoVineyard,DC=com' | Restore-ADObject -ErrorAction SilentlyContinue
Remove-ADUser Goofy -Confirm:$false

# Dismount-ADDatabase


#----Multi-value attribute demo: ServicePrincipalName----

<#
Example user multi-value attributes:
-Certificates                        
-CompoundIdentitySupported           
-dSCorePropagationData               
-KerberosEncryptionType              
-MemberOf                            
-PrincipalsAllowedToDelegateToAccount
-ServicePrincipalNames               
-SIDHistory                          
-userCertificate                     
#>


Get-ADComputer cvmember1 -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName

$server = Get-ADComputer cvmember1 -Properties ServicePrincipalName
$spn    = $server | Select-Object -ExpandProperty ServicePrincipalName

# Doh!  Run this line a couple times... Remove random SPNs!
Set-ADComputer -Identity $server -Remove @{"ServicePrincipalName"="$($spn | Get-Random)"}
# Add some bogus ones...
Set-ADComputer -Identity $server -Add @{ServicePrincipalName='FOO/CVWEB1'}
Set-ADComputer -Identity $server -Add @{ServicePrincipalName='FOO/CVWEB1.CohoVineyard.com'}

# After corruption
$Good = Get-ADComputer cvmember1 -Properties ServicePrincipalName -Server localhost:33389 | Select-Object -ExpandProperty ServicePrincipalName
$Bad  = Get-ADComputer cvmember1 -Properties ServicePrincipalName -Server localhost | Select-Object -ExpandProperty ServicePrincipalName
Compare-Object $Good $Bad -IncludeEqual

Get-ADComputer $server | Repair-ADAttribute -Property ServicePrincipalName -LDAPPort 33389

# After fix
$Good = Get-ADComputer cvmember1 -Properties ServicePrincipalName -Server localhost:33389 | Select-Object -ExpandProperty ServicePrincipalName
$Bad  = Get-ADComputer cvmember1 -Properties ServicePrincipalName -Server localhost | Select-Object -ExpandProperty ServicePrincipalName
Compare-Object $Good $Bad -IncludeEqual


# We could repair SPNs on users in the same way...
# Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property ServicePrincipalName -LDAPPort 33389 -WhatIf | ogv
# Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property ServicePrincipalName -LDAPPort 33389


#----Multiple Servers, Multiple Attributes-----

# Rerun corruption lines

Get-ADComputer -Filter * | Repair-ADAttribute -Property Description,ServicePrincipalName -LDAPPort 33389 | ogv



#---Group Memberships---

# Get-ADGroup returns an aliased property Members. It is not a real attribute.
# MemberOf is a backlink attribute that must be edited on the group containing the member.
Get-ADGroup "Domain Admins" -Properties Member | Select-Object -ExpandProperty Member
Add-ADGroupMember -Identity "Domain Admins" -Members Guest
Remove-ADGroupMember -Identity "Domain Admins" -Members "CN=Migration Destination,CN=Users,DC=CohoVineyard,DC=com" -Confirm:$false

$Good = Get-ADGroup "Domain Admins" -Properties Member -Server localhost:33389 | Select-Object -ExpandProperty Member
$Bad  = Get-ADGroup "Domain Admins" -Properties Member -Server localhost | Select-Object -ExpandProperty Member
Compare-Object $Good $Bad -IncludeEqual

Get-ADGroup "Domain Admins" | Repair-ADAttribute -Property member -LDAPPort 33389 | ogv

$Good = Get-ADGroup "Domain Admins" -Properties Member -Server localhost:33389 | Select-Object -ExpandProperty Member
$Bad  = Get-ADGroup "Domain Admins" -Properties Member -Server localhost | Select-Object -ExpandProperty Member
Compare-Object $Good $Bad -IncludeEqual

Dismount-ADDatabase





# REMOTING

# Windows Server 2008 R2 target

$cred = Get-Credential wingtiptoys\administrator
$s = New-PSSession -ComputerName dca.wingtiptoys.local -Credential $cred
Invoke-Command -Session $s -FilePath 'C:\Users\administrator.COHOVINEYARD\Documents\MVA\07 - Recovery\AD Snapshots\AD_Snapshot_Functions.ps1'
Invoke-Command -Session $s -ScriptBlock {Show-ADSnapshot}
Invoke-Command -Session $s -ScriptBlock {New-ADSnapshot}
Invoke-Command -Session $s -ScriptBlock {Show-ADSnapshot -wmi}
# Will get error "The server is not operational", expected
Invoke-Command -Session $s -ScriptBlock {Get-Process dsamain}
Invoke-Command -Session $s -ScriptBlock {Mount-ADDatabase -Last -LDAPPort 33389}
Invoke-Command -Session $s -ScriptBlock {Get-Process dsamain}
# View dsamain in remote server Task Manager processes
Invoke-Command -Session $s -ScriptBlock {ntdsutil snapshot "list mounted" quit quit}
Invoke-Command -Session $s -ScriptBlock {Get-ADUser Guest -Properties Description -Server localhost:33389}
Invoke-Command -Session $s -ScriptBlock {Get-ADUser Guest -Properties Description -Server localhost}
Invoke-Command -Session $s -ScriptBlock {Get-ADUser -filter {name -like "G*"}}
Invoke-Command -Session $s -ScriptBlock {Get-ADUser -filter {name -like "G*"} | Set-ADObject -Replace @{Description="foo"}}
Invoke-Command -Session $s -ScriptBlock {Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property Department,Description -LDAPPort 33389 -WhatIf} | ogv
Invoke-Command -Session $s -ScriptBlock {Get-ADUser -filter {name -like "G*"} | Repair-ADAttribute -Property Department,Description -LDAPPort 33389}
Invoke-Command -Session $s -ScriptBlock {Dismount-ADDatabase}
Invoke-Command -Session $s -ScriptBlock {Get-Process dsamain}
Invoke-Command -Session $s -ScriptBlock {Show-ADSnapshot}
# Invoke-Command -Session $s -ScriptBlock {Remove-ADSnapshot -All}
Invoke-Command -Session $s -ScriptBlock {Remove-ADSnapshot -Keep 3 -Last}
Remove-PSSession $s






# REMOTELY SCHEDULED SNAPSHOTS AND MANAGEMENT

<#
*Requires remoting enabled
*Works with PSv2
-Connect to all DCs
-List current snapshots
-Create a new snapshot
-Remove all snapshots past the last 5
-List current snapshots
-Disconnect

Schedule to run under proper credentials.
Could create a script that includes all of the commands at the bottom of the
function library to avoid multiple Invoke-Command statements.
#>

# Blast a new snapshot and purge to all DCs

$DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty Hostname
$cred = Get-Credential cohovineyard\administrator
$s = New-PSSession -ComputerName $DCs -Credential $cred
Get-PSSession
Invoke-Command -Session $s -FilePath 'C:\Users\administrator.COHOVINEYARD\Documents\PSHSummit\ADSnapshots\AD_Snapshot_Functions.ps1'
# Set ThrottleLimit to 1 to preserve the order of output returned
Invoke-Command -Session $s -ScriptBlock {"`n`n***************";hostname;Show-ADSnapshot} -ThrottleLimit 1
Invoke-Command -Session $s -ScriptBlock {"`n`n***************";hostname;New-ADSnapshot} -ThrottleLimit 1
Invoke-Command -Session $s -ScriptBlock {"`n`n***************";hostname;Remove-ADSnapshot -Keep 5 -Last} -ThrottleLimit 1
Invoke-Command -Session $s -ScriptBlock {"`n`n***************";hostname;Show-ADSnapshot} -ThrottleLimit 1
Remove-PSSession $s

