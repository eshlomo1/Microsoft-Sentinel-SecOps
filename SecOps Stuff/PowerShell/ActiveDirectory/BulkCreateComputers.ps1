##Source Learn Active Directory in a Month of Lunches
Import-Csv -Path C:\Scripts\ADLunches\computers.txt |
foreach {
 New-ADComputer -Enabled $true -Name $_.Name `
-Path:"CN=Computers,DC=Manticore,DC=org" `
-SamAccountName $_.Name   `
-Description $_.Description -PassThru
}

##Remove comments and place into a .csv file
#Name,Description
#ADLComp1, "Test Machine for AD Lunches"
#ADLComp2, "Test Machine for AD Lunches"
#ADLComp3, "Test Machine for AD Lunches"
