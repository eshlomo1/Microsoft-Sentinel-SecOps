break


# View the searcher properties
[ADSISEARCHER][ADSI]""

Get-Command Get-ADObject -Syntax

# -Identity

# samAccountName
Get-ADUser -Identity anlan
Get-ADUser -Identity $env:USERNAME
# SID
Get-ADUser -Identity S-1-5-21-2999376440-943117962-1153441346-1126
Get-ADUser -Identity (whoami /user /fo csv | ConvertFrom-Csv | Select-Object -ExpandProperty SID)
# DistinguishedName
Get-ADUser -Identity 'CN=anlan,OU=Migrated,DC=CohoVineyard,DC=com'
# ObjectGUID
Get-ADUser -Identity 91449dcc-cc57-4bcb-a945-37aa189ed356
# Etc.
Get-Help about_ActiveDirectory_Identity



# -Properties

# NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO
# Never use "filter star property star".
#  It's like going to the grocery and buying out the entire produce section.
#  Do you understand how many shopping carts (page size) that requires?
#  Then you come home and only eat one banana.
# Don't do it. Just don't.
Get-ADObject -Filter * -Property *
Get-ADUser -Filter * -Property *



# -SearchBase

# Popular search locations
Get-ADRootDSE | Select-Object -ExpandProperty namingContexts
($d = Get-ADRootDSE) | Get-Member -Name *Context | Select-Object -ExpandProperty Name | % {("{0,-40}" -f $_)+$d.$_}
($d = Get-ADDomain) | Get-Member -Name *Container | Select-Object -ExpandProperty Name | % {("{0,-40}" -f $_)+$d.$_}
($d = Get-ADForest) | Get-Member -Name *Container | Select-Object -ExpandProperty Name | % {("{0,-40}" -f $_)+$d.$_}

# Users container
Get-ADUser -Filter * -SearchBase (Get-ADDomain).UsersContainer | Format-Wide Name -AutoSize

# Computers container
Get-ADComputer -Filter * -SearchBase (Get-ADDomain).ComputersContainer | Format-Wide Name -AutoSize

# List of authorized DHCP servers
Get-ADObject -Filter * -Properties Created `
    -SearchBase ('CN=NetServices,CN=Services,'+(Get-ADRootDSE).configurationNamingContext) |
    Format-Table Name, Created -AutoSize

# Find a schema attribute
# Which logon attribute is in the global catalog?
Get-ADObject -LDAPFilter '(|(cn=Last-Logon)(cn=Last-Logon-Timestamp))' `
    -Properties isMemberOfPartialAttributeSet,lDAPDisplayName `
    -SearchBase (Get-ADRootDSE).schemaNamingContext |
    Format-Table Name, lDAPDisplayName, isMemberOfPartialAttributeSet -AutoSize

#------------------------------------------------------------------------------
# Schema update report
#------------------------------------------------------------------------------
$schema = Get-ADObject -SearchBase ((Get-ADRootDSE).schemaNamingContext) -SearchScope OneLevel -Filter * -Property objectClass, name, whenChanged, whenCreated | Select-Object objectClass, name, whenCreated, whenChanged, @{name="event";expression={($_.whenCreated).Date.ToShortDateString()}} | Sort-Object WhenCreated
"`nDetails of schema objects changed by date:"
$schema | ft objectClass, name, whenCreated, whenChanged -GroupBy event
"`nCount of schema objects changed by date:"
$schema | Group-Object event
#------------------------------------------------------------------------------


# -SearchScope

# Default SearchScope is SubTree
Get-ADObject -Filter * -SearchBase (Get-ADRootDSE).configurationNamingContext
# The object itself
Get-ADObject -Filter * -SearchBase (Get-ADRootDSE).configurationNamingContext -SearchScope Base
# The immediate child level
Get-ADObject -Filter * -SearchBase (Get-ADRootDSE).configurationNamingContext -SearchScope OneLevel
# Recursive child objects
Get-ADObject -Filter * -SearchBase (Get-ADRootDSE).configurationNamingContext -SearchScope Subtree


# -Server

# Local forest
Get-ADForest
# Trusted forest
Get-ADForest -Server dcA.wingtiptoys.local

#Global catalog
Get-ADUser administrator -Properties *
Get-ADUser administrator -Properties * -Server localhost:3268
Get-ADUser administrator -Properties * -Server cvdc1.cohovineyard.com:3268

# Fewer properties stored in the GC
Get-ADUser administrator -Properties * | Get-Member -MemberType Properties | Measure-Object
Get-ADUser administrator -Properties * -Server localhost:3268 | Get-Member -MemberType Properties | Measure-Object

# GC attributes have IsMemberOfPartialAttributeSet
# TRUE (LDAP boolean criteria is case-sensitive)
Get-ADObject -SearchBase ((Get-ADRootDSE).schemaNamingContext) -LDAPFilter 'IsMemberOfPartialAttributeSet=TRUE' -Properties Name, ObjectClass, IsMemberOfPartialAttributeSet | Sort-Object ObjectClass, Name | ft Name, ObjectClass, IsMemberOfPartialAttributeSet -AutoSize
# FALSE (LDAP boolean criteria is case-sensitive)
Get-ADObject -SearchBase ((Get-ADRootDSE).schemaNamingContext) -LDAPFilter '(|(IsMemberOfPartialAttributeSet=FALSE)(!IsMemberOfPartialAttributeSet=*))' -Properties Name, ObjectClass, IsMemberOfPartialAttributeSet | Sort-Object ObjectClass, Name | ft Name, ObjectClass, IsMemberOfPartialAttributeSet -AutoSize

Get-ADObject -LDAPFilter '(&(objectCategory=person)(objectClass=user)(name=a*))'


# -Credential

# Alternate credentials
Get-ADForest -Server dc1.tailspintoys.local -Credential (Get-Credential tailspintoys\administrator)
Get-ADUser administrator -Server dc1.tailspintoys.local -Credential (Get-Credential tailspintoys\administrator)


