Import-Csv -Path C:\Scripts\ADLunches\computers.txt |
foreach {
 New-ADComputer -Enabled $true -Name $_.Name `
-Path:"CN=Computers,DC=Manticore,DC=org" `
-SamAccountName $_.Name   `
-Description $_.Description -PassThru
}