# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney, Robert Merriman
# Date: 07/16/2014
# Description: Using PowerShell to get all AD users of a group and exports to .txt file.
# Comments: Change ADgroup to a portion of the name of the group you're looking for.
# ---------------------------------------------------


Get-ADGroup -filter 'Name -like"*ADgroup*"'  |
foreach{
$AD=$_.Name
$AD
$AD|Out-File -append c:\scripts\membersofadgroup.txt
$AD |Get-ADGroupMember|FT Name|Out-File -append c:\scripts\membersofadgroup.txt
}
