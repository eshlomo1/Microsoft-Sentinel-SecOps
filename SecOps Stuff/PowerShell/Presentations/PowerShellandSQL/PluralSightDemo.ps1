break

##Import SQLcmdlet Module & configure connection string
Import-Module SQLcmdlets
$ConnectionString = "server=SQL01\SQLEXPRESS;database=PluralSight;trusted_connection=true"

#Create object with SQL data
$ComputerData = Get-DatabaseData -connectionString $ConnectionString -query "Select * from Computers"

#Problem Returns number of quries found
$ComputerData
$ComputerData = $ComputerData[1..$ComputerData.Length]
$ComputerData

##Insert data to SQL
$Computer = Get-ADComputer -Identity SQL01 -Properties LastLogonDate,OperatingSystem,Description
$Computer

$query = "Insert Into Computers (SamAccountName,Name,SID,DistinguishedName,Domain,LastLogonDate,Description,OperatingSystem)
Values ('$($Computer.SamAccountName)','$($Computer.Name)','$($Computer.SID)','$($Computer.DistinguishedName)','Manticore.org','$($Computer.LastLogonDate)','$($Computer.Description)','$($Computer.OperatingSystem)')"

Invoke-DatabaseQuery -connectionString $ConnectionString -query $query

##Show SQL Computers table

#Insert Loop
$Users = Get-ADUser -Filter * -Properties mail,LastLogonDate,Description,CanonicalName
$Users
foreach ($User in $Users){

    $Domain = $User.CanonicalName.Split('/')
    $Domain = $Domain[0]

    $query = "Insert Into OmahaPSUG_Users (SamAccountName,UserPrincipalName,SID,Mail,DistinguishedName,Domain,LastLogonDate,Description)
    Values ('$($User.SamAccountName)','$($User.UserPrincipalName)','$($User.SID)','$($Computer.Mail)','$($User.DistinguishedName)','$Domain','$($User.LastLogonDate)','$($User.Description)')"

    Invoke-DatabaseQuery -connectionString $ConnectionString -query $query

}

#View SQL management studio visable data (No Mail populated)

#Get & Update SQL data

$UserPrincipalNames = (Get-DatabaseData -connectionString $ConnectionString -query "Select UserPrincipalName from OmahaPSUG_Users Where UserPrincipalName <> ' '").UserPrincipalName

Foreach ($UserPrincipalName in $UserPrincipalNames){

    $UpdateQuery = "Update OmahaPSUG_Users SET Mail = '$($UserPrincipalName)' where UserPrincipalName = '$($UserPrincipalName)'"

    Invoke-DatabaseQuery -connectionString $ConnectionString -query $UpdateQuery

}

##Load Copy-SQLTable function
psEdit C:\GitHub\PowerShell\SQL\Copy-SQLTable.ps1

##Copy one table to another
##Blog post http://duffney.github.io/CopySQLTable/
Copy-SQLTable -TableName 'OmahaPSUG_Computers' -SourceServer 'SQL01\SQLEXPRESS' -SourceDataBase 'OmahaPSUG' -TargetDatabase 'OmahaPSUG_BK' -TargetServer 'SQL01\SQLEXPRESS'

##Solutions Thinking (Stale AD Groups)
#Populate Groups
$Groups = Get-ADGroup -Filter {GroupCategory -eq 'Security'} -Properties ManagedBy -SearchBase 'OU=ADMLGroups,DC=manticore,DC=org'| ?{@(Get-ADGroupMember $_).Length -eq 0} 
#Get-ADGroup -Filter * -Properties ManagedBy,GroupCategory,GroupScope -SearchBase 'OU=Groups,DC=manticore,DC=org'

foreach ($Group in $Groups){

$MemberCount = (Get-ADGroupMember -Identity $Group.DistinguishedName).count
if($Group.ManagedBy -ne $null){
    $ManagedBy = (Get-ADUser -Identity $Group.ManagedBy).SamAccountName
} else {$ManagedBy = ''}

$query = "Insert Into OmahaPSUG_StaleGroups (SamAccountName,DistinguishedName,GroupCategory,GroupScope,MemberCount,ManagedBy)
Values ('$($Group.SamAccountName)','$($Group.DistinguishedName)','$($Group.GroupCategory)','$($Group.GroupScope)','$($MemberCount)','$($Managedby)')"

Invoke-DatabaseQuery -connectionString $ConnectionString -query $query

}

#Email Manager, Delete group update table 