break


### GO TO DCA.WINGTIPTOYS.LOCAL





# Cross-domain group issues

# Adding/removing members from another forest or domain to groups in Active Directory
# http://blogs.msdn.com/b/adpowershell/archive/2010/01/20/adding-removing-members-from-another-forest-or-domain-to-groups-in-active-directory.aspx
# http://social.technet.microsoft.com/Forums/windowsserver/en-US/b44c5459-b89a-4e7a-bb6f-3cd002635676/how-to-remove-a-domain-user-from-a-group-in-other-domain?forum=winserverpowershell#cd1ade69-0bc9-4ffd-9081-14175b8b944a

Import-Module ActiveDirectory

# This lab forest has three domains:
#    Root         wingtiptoys.local
#    Child        corp.wingtiptoys.local
#    Disjointed   disjointed.wideworldimporters.com

($f = Get-ADForest)
$f.Domains
$f.GlobalCatalogs

Get-ADDomain -Identity wingtiptoys.local
Get-ADDomain -Identity corp.wingtiptoys.local
Get-ADDomain -Identity disjointed.wideworldimporters.com

# Create a new universal group in the root domain
New-ADGroup -Name UG_Test -GroupCategory Security -GroupScope Universal

# Add a member from the local root domain
Add-ADGroupMember -Identity UG_Test -Members (Get-ADUser Guest)

# This command fails, because the cmdlet is looking at the local domain
Add-ADGroupMember -Identity UG_Test `
    -Members 'CN=Guest,CN=Users,DC=corp,DC=wingtiptoys,DC=local'

# This command fails, because the cmdlet is looking at the local domain even though targeting GC port
Add-ADGroupMember -Identity UG_Test `
    -Members 'CN=Guest,CN=Users,DC=corp,DC=wingtiptoys,DC=local' -Server localhost:3268

# Must get the external domain member by targeting a DC in that domain
# Instead of specifying a DC name, we'll use the domain name itself
# and get a DC name via round robin DNS for the domain.
Add-ADGroupMember -Identity UG_Test `
    -Members (Get-ADUser Guest -Server corp.wingtiptoys.local)
Add-ADGroupMember -Identity UG_Test `
    -Members (Get-ADUser Guest -Server disjointed.wideworldimporters.com)

# View the members
Get-ADGroup UG_Test -Properties Members
Get-ADGroupMember UG_Test

# This next command will error, trying to remove a external domain member
Remove-ADGroupMember -Identity UG_Test -Confirm:$false `
    -Members (Get-ADUser Guest -Server disjointed.wideworldimporters.com)

# This next command will error. Try looking at just the DistinguishedName.
Remove-ADGroupMember -Identity UG_Test -Confirm:$false `
    -Members (Get-ADUser Guest -Server disjointed.wideworldimporters.com).DistinguishedName

# This next command will error, trying to remove a external domain member
$wwiGuest = Get-ADUser Guest -Server disjointed.wideworldimporters.com
Remove-ADGroupMember -Identity UG_Test -Confirm:$false -Members $wwiGuest

# View the raw Member attribute contents
Get-ADObject -Identity (Get-ADGroup UG_Test) -Properties Member | Select-Object -ExpandProperty Member

# Selectively remove the multi-value attribute value of the external domain member
Set-ADObject -Identity (Get-ADGroup UG_Test) -Remove @{Member=$((Get-ADUser Guest -Server corp.wingtiptoys.local).DistinguishedName)}

# View the members
Get-ADGroupMember UG_Test

# Wipe all group members
Set-ADObject -Identity (Get-ADGroup UG_Test) -Clear Member

# Remove the group
Remove-ADGroup UG_Test
