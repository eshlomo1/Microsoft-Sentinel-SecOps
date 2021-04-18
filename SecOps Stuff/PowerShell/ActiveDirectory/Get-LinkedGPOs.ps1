$gpos = Get-GPInheritance -Target "OU=ADMLUsers,DC=manticore,DC=org"
$linked = $gpos.GpoLinks | select -ExpandProperty DisplayName
$gpos | select -ExpandProperty GpoLinks
$gpos | select -ExpandProperty InheritedGpoLinks |where DisplayName -NotIn $linked 