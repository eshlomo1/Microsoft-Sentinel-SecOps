Import-Csv -Path C:\Scripts\ADLunches\computersTodelete.txt |
foreach {
 Remove-ADComputer -Identity $_.Name -Confirm:$false 
}