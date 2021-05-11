(Get-ADGroup -Filter {GroupScope -eq "Global"} | Where-Object Name -NotMatch "Administrators").Name
