<#
 Listing 9.1 from:
  Active Directory Management in a Month of Lunches
  Chapter 09

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>

$gpolinks = Get-ADOrganizationalUnit -Filter * |               #1
where LinkedGroupPolicyObjects |                               #2
foreach {
 $ou = $_.DistinguishedName
 $_.LinkedGroupPolicyObjects |                                 #3
 foreach {
   $x = $_.ToUpper() -split ",", 2
   $id = $x[0].Replace("CN={","").Replace("}","")
   $props = [ordered]@{
    OU = $ou
    GPO = Get-GPO -Guid $id | select -ExpandProperty DisplayName #4
   }
   New-Object -TypeName PSObject -Property $props
 }
}
$gpolinks | sort OU | Format-Table OU, GPO -AutoSize
$gpolinks | sort GPO | Format-Table GPO, OU -AutoSize 
