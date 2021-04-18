Import-Module SQLcmdlets
$ConnectionString = "server=SQL01\SQLEXPRESS;database=OmahaPSUG;trusted_connection=true"
$ConnectionStringOmahaPSUGBK = "server=SQL01\SQLEXPRESS;database=OmahaPSUG_BK;trusted_connection=true"

Invoke-DatabaseQuery -connectionString $ConnectionString -query "Delete From OmahaPSUG_Users"
Invoke-DatabaseQuery -connectionString $ConnectionString -query "Delete From OmahaPSUG_Computers"
Invoke-DatabaseQuery -connectionString $ConnectionString -query "Delete From OmahaPSUG_StaleGroups"
Invoke-DatabaseQuery -connectionString $ConnectionStringOmahaPSUGBK -query "Delete From OmahaPSUG_Computers"
Set-ADComputer -Identity DC01 -Location $null -Verbose

$Computer = Get-ADComputer -Identity DC01 -Properties LastLogonDate,OperatingSystem,Description

$query = "Insert Into OmahaPSUG_Computers (SamAccountName,Name,SID,DistinguishedName,Domain,LastLogonDate,Description,OperatingSystem)
Values ('$($Computer.SamAccountName)','$($Computer.Name)','$($Computer.SID)','$($Computer.DistinguishedName)','Manticore.org','$($Computer.LastLogonDate)','$($Computer.Description)','$($Computer.OperatingSystem)')"

Invoke-DatabaseQuery -connectionString $ConnectionString -query $query