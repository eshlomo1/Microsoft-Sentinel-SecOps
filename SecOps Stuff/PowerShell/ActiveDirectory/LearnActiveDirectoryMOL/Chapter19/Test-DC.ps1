<#
 Sample lab answer from:
  Active Directory Management in a Month of Lunches
  Chapter 19

  This script performs tests against one or more domain controllers
  to determine if DC availability is affecting logon

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>

function test-dc {
[CmdletBinding()]
param 
( 
  [string[]]$dcs
)

foreach ($dc in $dcs) {
  $DCstate = [ordered]@{}
  $DCstate += @{"DCname" = $dc}
   
  ## ping test
  $pingable =  Test-Connection -ComputerName $dc -Quiet -Count 1
  $DCstate += @{"Pingable" = $pingable}
  
  ## NTDS service
  $ntdsState = (Get-Service -Name NTDS -ComputerName $dc).Status
  $DCstate += @{"NTDSstatus" = $ntdsState}

  # perfrom AD lookup
  $ADlookup = $null
  $ADlookup = Get-ADUser –Identity "jduffney" –Server $dc
  
  if ($ADlookup)
  {
    $DCstate += @{"ADLookup" = $true}
  }
  else
  {
    $DCstate += @{"ADLookup" = $false}
  } 
  
  New-Object -TypeName PSObject -Property $DCstate
   
} # end outer foreach
} # end of function

$domaincontrollers = Get-ADComputer -Filter * -SearchBase (Get-ADDomain | select -ExpandProperty DomainControllersContainer) | 
select -ExpandProperty DNSHostName

test-dc -dcs $domaincontrollers