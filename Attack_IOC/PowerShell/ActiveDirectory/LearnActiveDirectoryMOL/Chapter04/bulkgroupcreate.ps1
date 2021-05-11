Import-Csv -Path .\groups.csv |
foreach {
  New-ADGroup -Name $_.Name -Path "CN=Users,DC=Manticore,DC=org" `
  -GroupCategory Security -GroupScope Global `
  -Description $_.Description
}