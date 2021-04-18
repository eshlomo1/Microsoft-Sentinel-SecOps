$ous = @()
$dom = Get-ADDomain

$ous += "CN=Builtin,$($dom.DistinguishedName)"
$ous += "CN=Users,$($dom.DistinguishedName)"

foreach ($ou in $ous){
  $groups = Get-ADGroup -SearchBase $ou -Filter * |
   where {$_.Name -ne 'Domain Users' -and $_.Name -ne 'Domain Computers'}
 foreach ($group in $groups){
  Get-ADGroupMember -Identity $group.DistinguishedName |
  select @{Name='OU'; Expression={$ou}},
  @{Name='Group'; Expression={$group.Name}},
  @{Name='Member'; Expression={$psitem.Name}}
 }
}