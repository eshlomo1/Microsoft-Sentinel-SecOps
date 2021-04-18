break

Get-Help about_ActiveDirectory_Identity
Get-Help about_ActiveDirectory_ObjectModel


# Raw object vs Tricked-out object
Get-ADObject -LDAPFilter '(&(objectClass=group)(cn=Administrators))' -Properties GroupType | fl Name, GroupType
Get-ADGroup Administrators | fl Name, GroupCategory, GroupScope

Get-ADObject -LDAPFilter '(&(objectClass=user)(cn=Guest))' -Properties UserAccountControl | fl Name, UserAccountControl
Get-ADUser Guest -Properties * | fl Name, Enabled, LockedOut, PasswordExpired

Get-ADObject -LDAPFilter '(&(objectClass=computer)(cn=CVDC1))' -Properties * | fl LastLogon, DNSHostName
Get-ADComputer CVDC1 -Properties * | fl LastLogon, LastLogonDate, DNSHostName, IPv4Address


# Cmdlets
Get-Command -Noun ADUser
Get-Command -Noun ADComputer
Get-Command -Noun Computer
Get-Command -Noun ADGroup
Get-Command -Noun ADOrganizationalUnit

