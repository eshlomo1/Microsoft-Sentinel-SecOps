break

# Active Directory for Windows PowerShell About Help Topics
# http://technet.microsoft.com/en-us/library/hh531525(v=ws.10).aspx
Get-Help about_ActiveDirectory_Filter
Get-Help about_ActiveDirectory_ObjectModel

# Search Filters
# http://technet.microsoft.com/en-us/library/cc978015.aspx

# Use ADUC to cheat and write your LDAP query string



# Demo ADUser cmdlets:
# - Filter is a required parameter if username is omitted
# - Must use "-property *" to get all properties
# - Capture $user and pipe into a set or get so that you don't have to type the distinguished name
get-aduser -filter *
get-aduser -filter {name -eq 'anlan'}
get-aduser S-1-5-21-2999376440-943117962-1153441346-1126

#get all users, all properties - bad
get-aduser -filter * -Properties *

#get all users, department - still not great
get-aduser -filter * -Properties Department

#get all users in OU
get-aduser -filter * -SearchBase "OU=migrated,DC=cohovineyard,DC=com"


# about_ActiveDirectory_Filter

Get-ADObject -LDAPFilter '(cn=bob*)'
Get-ADObject -Filter 'CN -like "*bob*"'

Get-ADUser -LDAPFilter '(&(badpwdcount>=5)(badpwdcount=*))'
Get-ADUser -Filter 'badpwdcount -ge 5'

Get-ADObject -LDAPFilter '(&(objectClass=user)(email=*))'
Get-ADUser -filter 'email -like "*"'
Get-ADObject -filter 'email -like "*" -and ObjectClass -eq "user"'

Get-ADObject -LDAPFilter '(&(sn=smith)(objectClass=user)(email=*))'
Get-ADUser -Filter 'Email -like "*" -and SurName -eq "smith"'
Get-ADUser -Filter 'Email -like "*" -and sn -eq "smith"'

Get-ADObject -LDAPFilter '(&(objectClass=user)(|(cn=and*)(cn=steve)(cn=margaret)))'
Get-ADUser -Filter 'CN -like "and*" -or CN -eq "steve" -or CN -eq "margaret"'
Get-ADObject -Filter 'objectClass -eq "user" -and (CN -like "and*" -or CN -eq "steve" -or CN -eq "margaret")'

Get-ADUser -LDAPFilter '(!(email=*))'
Get-ADUser -Filter '-not Email -like "*"'
Get-ADUser -Filter 'Email -notlike "*"'

# No logon in 5 days
Get-ADObject -LDAPFilter '(&(lastLogon<=128812906535515110)(objectClass=user)(!(objectClass=computer)))'
$date = (Get-Date) - (New-TimeSpan -Days 5)
Get-ADUser -Filter 'lastLogon -lt $date'



# Query all meaningful demographic data
Get-ADUser -LDAPFilter "(&(department=*)(cn=a*))" -Property SamAccountName, GivenName, Surname, DisplayName, Department, OfficePhone, City, State | 
    Select-Object SamAccountName, GivenName, Surname, DisplayName, Department, OfficePhone, City, State -First 15| 
    ft * -AutoSize

# Query everyone in the Legal department
Get-ADUser -LDAPFilter "(department=Legal)" -Property SamAccountName, GivenName, Surname, DisplayName, City, State | 
    Select-Object SamAccountName, GivenName, Surname, DisplayName, City, State -First 15| 
    ft * -AutoSize


# Find a schema attribute
# Which logon attribute is in the global catalog?
Get-ADObject -LDAPFilter '(|(cn=Last-Logon)(cn=Last-Logon-Timestamp))' `
    -Properties isMemberOfPartialAttributeSet,lDAPDisplayName `
    -SearchBase (Get-ADRootDSE).schemaNamingContext |
    Format-Table Name, lDAPDisplayName, isMemberOfPartialAttributeSet -AutoSize

#------------------------------------------------------------------------------
# Group membership advanced search within nested groups
# Demonstrates the "-RecursiveMatch" LDAP operator, link chain checking.
# See about_ActiveDirectory_Filter
#------------------------------------------------------------------------------

# Create the groups
New-ADGroup GroupLevel1 -GroupScope Global
New-ADGroup GroupLevel2 -GroupScope Global
New-ADGroup GroupLevel3 -GroupScope Global

# Nest the members
Add-ADGroupMember -Identity GroupLevel1 -Members GroupLevel2
Add-ADGroupMember -Identity GroupLevel2 -Members GroupLevel3
Add-ADGroupMember -Identity GroupLevel3 -Members Guest

# View the results
Get-ADGroup -Filter 'name -like "GroupLevel*"' -Properties MemberOf, Members | ft Name, Members, MemberOf -AutoSize
Get-ADUser Guest -Properties MemberOf | ft Name, MemberOf -AutoSize

# Recursively a nested member of GroupLevel1?
Get-ADUser `
    -Filter 'memberOf -RecursiveMatch "CN=GroupLevel1,CN=Users,DC=CohoVineyard,DC=com"' `
    -SearchBase "CN=guest,CN=Users,DC=cohovineyard,DC=com"

# Recursively a nested member of Domain Admins?
Get-ADUser `
    -Filter "memberOf -RecursiveMatch '$((Get-ADGroup "Domain Admins").DistinguishedName)'" `
    -SearchBase $((Get-ADUser Guest).DistinguishedName)

# Nest the group in domain admins
Add-ADGroupMember -Identity "Domain Admins" -Members (Get-ADGroup GroupLevel1)
Get-ADGroup -Filter 'name -like "GroupLevel*"' -Properties MemberOf, Members | ft Name, Members, MemberOf -AutoSize

# Recursively a nested member of Domain Admins?
Get-ADUser `
    -Filter "memberOf -RecursiveMatch '$((Get-ADGroup "Domain Admins").DistinguishedName)'" `
    -SearchBase $((Get-ADUser Guest).DistinguishedName)

# Let's it make a function!
Function Test-ADDomainAdmin {
Param ($user)
    trap {return "error"}
    If (
        Get-ADUser `
            -Filter "memberOf -RecursiveMatch '$((Get-ADGroup "Domain Admins").DistinguishedName)'" `
            -SearchBase $((Get-ADUser $user).DistinguishedName)
        ) {$true}
        Else {$false}
}

Test-ADDomainAdmin Guest
Test-ADDomainAdmin anlan
Test-ADDomainAdmin bogus

# Remove the groups
Get-ADGroup -Filter 'name -like "GroupLevel*"' | Remove-ADGroup -Confirm:$true

# Now validate that Guest is no long a domain admin
Test-ADDomainAdmin Guest


<#
How to use the UserAccountControl flags to manipulate user account properties
http://support.microsoft.com/kb/305144

Property flag,Value in hexadecimal,Value in decimal

 SCRIPT 0x0001 1 
*ACCOUNTDISABLE 0x0002 2 
 HOMEDIR_REQUIRED 0x0008 8 
*LOCKOUT 0x0010 16 
*PASSWD_NOTREQD 0x0020 32 
*PASSWD_CANT_CHANGE Note You cannot assign this permission by directly modifying the UserAccountControl attribute. For information about how to set the permission programmatically, see the "Property flag descriptions" section.  0x0040 64 
 ENCRYPTED_TEXT_PWD_ALLOWED 0x0080 128 
 TEMP_DUPLICATE_ACCOUNT 0x0100 256 
 NORMAL_ACCOUNT 0x0200 512 
 INTERDOMAIN_TRUST_ACCOUNT 0x0800 2048 
 WORKSTATION_TRUST_ACCOUNT 0x1000 4096 
 SERVER_TRUST_ACCOUNT 0x2000 8192 
 DONT_EXPIRE_PASSWORD 0x10000 65536 
 MNS_LOGON_ACCOUNT 0x20000 131072 
 SMARTCARD_REQUIRED 0x40000 262144 
 TRUSTED_FOR_DELEGATION 0x80000 524288 
 NOT_DELEGATED 0x100000 1048576 
 USE_DES_KEY_ONLY 0x200000 2097152 
 DONT_REQ_PREAUTH 0x400000 4194304 
*PASSWORD_EXPIRED 0x800000 8388608 
 TRUSTED_TO_AUTH_FOR_DELEGATION 0x1000000 16777216 
 PARTIAL_SECRETS_ACCOUNT 0x04000000   67108864

TIP: 2 Ways userAccountControl Is Easier In AD PowerShell
http://blogs.technet.com/b/ashleymcglone/archive/2012/12/13/tip-2-ways-useraccountcontrol-is-easier-in-ad-powershell.aspx
#>


# Accounts with PasswordNotRequired set (32)
Get-ADUser -LDAPFilter '(userAccountControl:1.2.840.113556.1.4.803:=32)'
Get-ADObject -Filter {userAccountControl -band 32}

# Accounts with "DES only" set
Get-ADUser -LDAPFilter '(userAccountControl:1.2.840.113556.1.4.803:=2097152)'
Get-ADUser -Filter {userAccountControl -band 2097152}

# Search-ADAccount has parameters for some
Get-Command Search-ADAccount -Syntax
Search-ADAccount -AccountDisabled
Get-ADUser -LDAPFilter '(userAccountControl:1.2.840.113556.1.4.803:=2)'
Get-ADUser -Filter {userAccountControl -band 2}


#List all manual replication connections
Get-ADObject `
    -LDAPFilter "(&(objectClass=nTDSConnection)(!options:1.2.840.113556.1.4.804:=1))" `
    -Searchbase (Get-ADRootDSE).ConfigurationNamingContext `
    -Property DistinguishedName, FromServer | Format-Table DistinguishedName, FromServer




