New-ADGroup -Name ADLcomputers -Description "Test group for computers" -GroupCategory Security -GroupScope Global -Path "cn=Computers,dc=Manticore,dc=org"

"ADLComp1", "ADLComp2" |
foreach {
 New-ADComputer -Name $_ -Path "cn=Computers,dc=Manticore,dc=org"
}

Add-ADGroupMember -Identity ADLcomputers -Members (Get-ADComputer -Filter {Name -like "ADLcomp*"})

Get-ADGroupMember -Identity ADLComputers