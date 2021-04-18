break

# Reverse engineer the highest accounts/groups

# Use this when the big accounts and groups have been renamed.
# Extrapolate other privileged groups and accounts using the formula below to construct their SIDs.

Import-Module ActiveDirectory

# Calculate the SIDs of the highest privileged user and groups
$SID_GROUP_EA = [System.Security.Principal.SecurityIdentifier]"$((Get-ADDomain -Identity (Get-ADForest).Name).DomainSID)-519"
$SID_GROUP_DA = [System.Security.Principal.SecurityIdentifier]"$((Get-ADDomain).DomainSID)-512"
$SID_GROUP_AD = [System.Security.Principal.SecurityIdentifier]'S-1-5-32-544'
$SID_USER_AD  = [System.Security.Principal.SecurityIdentifier]"$((Get-ADDomain).DomainSID)-500"

# Get each one of these privileged security principals
Get-ADGroup $SID_GROUP_EA -Properties * -Server (Get-ADForest).Name
Get-ADGroup $SID_GROUP_DA -Properties *
Get-ADGroup $SID_GROUP_AD -Properties *
Get-ADUser  $SID_USER_AD  -Properties *

