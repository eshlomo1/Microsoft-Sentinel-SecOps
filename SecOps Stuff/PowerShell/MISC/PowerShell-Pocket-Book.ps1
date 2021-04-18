Active Directory

--Show members of a group and outputs to a grid--
(Get-ADUser -Identity regis.tiebi -Properties memberof | Select-Object memberof).memberof | out-gridview
Get-ADPrincipalGroupMembership username | select name


--Show all members of an Active Directory group--
Get-ADGroupMember "Groupname" | out-gridview {Out-gridview is option}
--Remove AD user from a group--

Remove-ADGroupMember -Identity "Groupname" -Members "Username"
--Add AD user to Group--

Add-ADGroupMember Groupname Username.
--Create new AD user and specify OU path--

New-ADUser -Name HSG_TestChild -Path "ou=HSG_TestOU1,ou=HSG_TestOU,dc=nwtraders,dc=com"
--Get-ADUser--
Get-ADUser -Identity "Username"

--Enabled AD User--
Enabled-ADaccount -identity username

--Set-ADuser Description--
Set-ADUser -Identity KPE.PD -Description "text"

--Set-ADuser Manager--
Method 1: Modify the Manager property for the "saraDavis" user by using the Identity and Manager parameters.
Set-ADUser -Identity "saraDavis" -Manager "JimCorbin"
Method 2: Modify the Manager property for the "saraDavis" user by passing the "saraDavis" user through the pipeline and specifying the Manager parameter.
Get-ADUser -Identity "saraDavis" | Set-ADUser -Manager "JimCorbin"
Method 3: Modify the Manager property for the "saraDavis" user by using the Windows PowerShell command line to modify a local instance of the "saraDavis" user. Then set the Instance parameter to the local instance.
$user = Get-ADUser -Identity "saraDavis" 
$user.Manager = "JimCorbin"
Set-ADUser -Instance $user.

--Move AD user--
 Get-ADUser -Identity username | Move-ADObject -TargetPath "OU=Partners,OU=Users,OU=Kiewit,DC=domain,DC=COM"
--Append Discritption to user--

get-aduser cduff -Properties Description | ForEach-Object { Set-ADUser $_ -Description "$($_.Description) Some more stuff" }

--Search for AD User--
 Get-ADUser -Filter { name -like "joshua.d*" } | Select Name

--Reset AD user account password--
Set-ADAccountPassword -Identity ecd.miltonyard -Reset

-- Export User name and Email to CSV file --
Get-ADGroupMember -Identity groupname -Recursive | get-aduser -Properties Mail | Select Name,Mail |Export-CSV -Path C:\file.csv -NoTypeInformation
Exchange

--Get Mailbox Size--
Get-MailboxStatistics username | Format-List StorageLimitStatus,TotalItemSize,TotalDeletedItemSize,ItemCount,DeletedItemCount
