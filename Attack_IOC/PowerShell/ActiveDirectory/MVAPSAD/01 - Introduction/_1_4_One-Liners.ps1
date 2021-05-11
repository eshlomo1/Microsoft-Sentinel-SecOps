break

# List of all domain controllers
Get-ADDomainController -Filter * | Format-Table Name, Domain, Forest, Site, IPv4Address, OperatingSystem, OperationMasterRoles -AutoSize

# Account unlock
Read-Host "Enter the user account to unlock" | Unlock-ADAccount

# Password reset
Set-ADAccountPassword (Read-Host 'User') -Reset


# Reset Password
# User must change password at next logon
# Alternate credentials
Set-ADAccountPassword -Cr ($c=Get-Credential) -S ($s=Read-Host 'DC') -I ($u=Read-Host 'User') -R;Set-ADUser $u -Ch 1 -Cr $c -Server $s


#List all manual replication connections
Get-ADObject -LDAPFilter "(&(objectClass=nTDSConnection)(!options:1.2.840.113556.1.4.804:=1))" -Searchbase (Get-ADRootDSE).ConfigurationNamingContext -Property DistinguishedName, FromServer | Format-Table DistinguishedName, FromServer 


# Modify all sitelinks
Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{Cost=100;ReplInterval=15;Options=5} -Confirm



# Password reset

: 100 characters
: Reset Password
@echo off&&powershell -NoE -C "&{ipmo ActiveDirectory;Set-ADAccountPassword (Read-Host 'User') -R}"

: 123 characters
: Reset Password
: User must change password at next logon
@echo off&&powershell -NoE -C "&{ipmo ActiveDirectory;Set-ADAccountPassword ($u=Read-Host 'User') -R;Set-ADUser $u -Ch 1}"

: 154 characters
: Reset Password
: User must change password at next logon
: Alternate credentials
@echo off&&powershell -NoE -C "&{ipmo ActiveDirectory;Set-ADAccountPassword ($u=Read-Host 'User') -R -Cr ($c=Get-Credential);Set-ADUser $u -Ch 1 -Cr $c}"

: 191 characters
: Reset Password
: User must change password at next logon
: Alternate credentials
: Target a specific DC
@echo off&&powershell -NoE -C "&{ipmo ActiveDirectory;Set-ADAccountPassword -Cr ($c=Get-Credential) -S ($s=Read-Host 'DC') -I ($u=Read-Host 'User') -R;Set-ADUser $u -Ch 1 -Cr $c -Server $s}"

