# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney
# Date: 07/16/2014
# Description: Using PowerShell to enable mass amount of users accounts & sets account expiration.
# Comments: Populate the enableuser.txt with the names of disabled users accounts.
# ---------------------------------------------------


Import-Module activedirectory
$File = "C:\scripts\enableusers.txt"

ForEach ($User in (Get-Content $File))
{ Enable-ADAccount -Identity $User ; Set-ADAccountExpiration -Identity $User 12/31/2014
}
