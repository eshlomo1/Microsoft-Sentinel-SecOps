import-csv C:\Scripts\ADLunches\ous.txt |
foreach {
New-ADOrganizationalUnit -Name $_.Name -Path $_.Path `
-ProtectedFromAccidentalDeletion $true -PassThru
}