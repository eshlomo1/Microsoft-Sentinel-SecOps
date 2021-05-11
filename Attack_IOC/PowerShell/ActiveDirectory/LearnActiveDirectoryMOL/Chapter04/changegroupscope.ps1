"ADLgroup3", "ADLgroup4", "ADLgroup5", "ADLgroup6" | foreach {Set-ADGroup -Identity  $_ -GroupScope Universal}
"ADLgroup3", "ADLgroup4" | foreach {Set-ADGroup -Identity  $_ -GroupScope DomainLocal }