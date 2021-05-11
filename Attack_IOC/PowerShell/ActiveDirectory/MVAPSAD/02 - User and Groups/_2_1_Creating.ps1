break


# The hard way... ADSI.

# We have to connect to the parent container and
# then call the Create method, passing the object type and CN.
$UserContainer = [ADSI]"LDAP://CN=Users,$(([ADSI]"LDAP://RootDSE").defaultNamingContext)"
$User = $UserContainer.Create("user","CN=Alice")
# We must create the user with SetInfo before we can populate properties.
$User.SetInfo()

# Now we can set the description.
$User.Put("description","ADSI test user")
$User.SetInfo()

# Finally we'll delete the user.
$UserContainer.Delete("user","CN=Alice")



# The easy way... PowerShell.

# Syntax
Get-Command -Syntax New-ADUser

# By itself to understand required properties
New-ADUser


new-aduser ron
get-aduser ron
$user = get-aduser ron
$user | gm
$user = get-aduser ron -property *
$user | gm
$user = new-aduser "PowerShell Ninja"
$user | set-adobject -Description "I will rule the world!"


# New accounts are disabled by default.
#  ERROR
Enable-ADAccount ron

# Set password & enable account
$pw = Read-Host "What is the password?" -AsSecureString
Set-ADAccountPassword ron -NewPassword $pw
Enable-ADAccount ron



# New user, enabled, password... in one line.
New-ADUser Jim -Enabled $True -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force)
Get-ADUser jim

# Look at all those parameters!
Get-Command New-ADUser -Syntax



# View users from CSV
Import-CSV ".\users.csv" | Out-GridView

# Import users from CSV
Import-CSV ".\users.csv" | New-ADUser

# Import users from CSV, set password, enable
Import-CSV ".\users.csv" | 
    New-ADUser `
        -Enabled $True `
        -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force)

# Import users from CSV, set other properties on import
Import-CSV ".\users.csv" | 
    New-ADUser `
        -Enabled $True `
        -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force) `
        -Company 'Coho Vineyard, Inc.'

# Import users from CSV, set destination OU
Import-CSV ".\users.csv" | 
    New-ADUser `
        -Enabled $True `
        -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force) `
        -Company 'Coho Vineyard, Inc.' `
        -Path 'OU=NewUsers,DC=cohovineyard,DC=com'



# Import users from CSV when the columns do not match

New-ADOrganizationalUnit NewUsers

Import-CSV ".\newusers.csv" | ogv

# MUST INCLUDE NAME AND SAMACCOUNTNAME ON IMPORT

Import-CSV ".\newusers.csv" | Select-Object Title, Department, City, State, Office, EmployeeID, `
    @{name='name';expression={($_.'First Name'.substring(0,3)+$_.'Last Name').substring(0,7).toLower()}}, `
    @{name='samAccountName';expression={($_.'First Name'.substring(0,3)+$_.'Last Name').substring(0,7).toLower()}}, `
    @{name='displayName';expression={$_.'First Name'+' '+$_.'Last Name'}}, `
    @{name='givenName';expression={$_.'First Name'}}, `
    @{name='surName';expression={$_.'Last Name'}}, `
    @{name='path';expression={'OU=NewUsers,DC=cohovineyard,DC=com'}} |
    Out-GridView

Import-CSV ".\newusers.csv" | Select-Object Title, Department, City, State, Office, EmployeeID, `
    @{name='name';expression={($_.'First Name'.substring(0,3)+$_.'Last Name').substring(0,7).toLower()}}, `
    @{name='samAccountName';expression={($_.'First Name'.substring(0,3)+$_.'Last Name').substring(0,7).toLower()}}, `
    @{name='displayName';expression={$_.'First Name'+' '+$_.'Last Name'}}, `
    @{name='givenName';expression={$_.'First Name'}}, `
    @{name='surName';expression={$_.'Last Name'}} |
    New-ADUser -ChangePasswordAtLogon $true -Enabled $True -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force) -Path 'OU=NewUsers,DC=cohovineyard,DC=com' -PassThru

Get-ADUser -Filter 'Office -eq "MVA"' | ogv

# Get-ADUser -Filter 'Office -eq "MVA"' | Remove-ADUser -Confirm:$false

# Use this same technique for groups, OUs, subnets, sites, etc.






#------------------------------------------------------------------------------
# PART 1:  Build users and OUs from scratch
#------------------------------------------------------------------------------

#In ADUC show the Users container without our test users.

# Must have Name and SamAccountName columns in the CSV for this to work.
# Works because column titles match parameter names.
# In order the import when column titles don't match, you must use
# Select-Object to rename the columns to match the New-ADUser parameters.

# This line would import all users, but they would be disabled without a password.
# DO NOT RUN THIS DEMO VERSION:  Import-CSV "C:\ADPS\users.csv" | New-ADUser
# Add switches to enable account and set password,
# since account has to be enabled for mailbox creation.
# Note that you can add any additional properties as parameters on the import.
Import-CSV ".\users.csv" | 
 New-ADUser -Enabled $True -AccountPassword $(ConvertTo-SecureString "P@55word" -AsPlainText -Force)

#In ADUC show all of the new users in the Users container.

#Dynamically query all user departments and create root OUs of the same names
Get-ADUser -LDAPFilter "(department=*)" -Property Department | 
    Sort-Object Department -Unique | Select-Object Department | 
    ForEach-Object {New-ADOrganizationalUnit $_.Department -ProtectedFromAccidentalDeletion $false}

#Move all users to OU of department name
$rootDN = (Get-ADDomain).DistinguishedName
Get-ADUser -LDAPFilter "(department=*)" -Property Department, DistinguishedName | 
    ForEach-Object {Move-ADObject -Identity $_.Distinguishedname -Targetpath "OU=$($_.Department),$rootDN"}

#In ADUC show all of the new users in the OUs with department names.







$rootDN = (Get-ADDomain).DistinguishedName
New-ADGroup -Path "OU=HR,$rootDN" -Name "DL-HR" -GroupScope DomainLocal  -GroupCategory Distribution
New-ADGroup -Path "OU=Engineering,$rootDN" -Name "DL-Engineering" -GroupScope DomainLocal -GroupCategory Distribution

New-ADOrganizationalUnit Engineering

Get-ADGroup dl-engineering

New-ADGroup -SamAccountName 'G_Purchasing' -GroupScope Global -GroupCategory Security
Get-ADGroup G_Purchasing | Add-ADGroupMember Ron

Add-ADGroupMember -Identity G_Purchasing -Members (Get-ADUser Ron)
