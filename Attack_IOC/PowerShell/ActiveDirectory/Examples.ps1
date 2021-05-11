Get-ADuser –filter * -properties * | ft name,department

Get-ADUser –Filter * -Properties * | sort –Property Department | ft Name,Department

Get-ADUser –filter {Department –eq “Sales” –or Department –eq “Marketing”} –Properties * | ft –Property Surname,Department,PasswordLastSet

Get-ADComputer –filter * | % {Get-hotfix –computername $PSItem.Name}

Get-ADComputer –filter * | % {Invoke-command $PSitem.Name –scriptblock { get-hotfix}}

Get-ADGroupMember -Identity 'domain controllers' | % {Get-ADComputer $PSItem.Name -Properties OperatingSystem} | select Name,OperatingSystem
#Add Computers to groups in PowerShell
Set-ADGroup -Add:@{'Member'="CN=WEFS1,CN=Computers,DC=WEF,DC=COM"} -Identity:"CN=Event Log Readers,CN=Builtin,DC=WEF,DC=COM" -Server:"WEFDC.WEF.COM"
help about_active*
