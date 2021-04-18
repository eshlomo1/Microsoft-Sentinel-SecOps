<#
 Sample lab answer from:
  Active Directory Management in a Month of Lunches
  Chapter 19

  This script performs tests user logon capability

 All code supplied "as is" as an example to illustrate the text. No guarantees or warranties are supplied with this code.
 It is YOUR responsibilty to test if for suitability in YOUR environment.
 The comments match the section headings in the chapter
#>

function convertTO-LogonHours {
param (
 [byte]$byte
)
 $result = ""
 0..7 | foreach {
   $result += $onoff[($byte -band $power2[$psitem]) -ne 0]
 }
 
 $result 
}

function test-userlogon {
[CmdletBinding()]
param 
( 
  [string]$user,
  [string]$pc,
  [string]$dc,
  [switch]$testdns
)

$logontests = [ordered]@{}
$logontests += @{"User" = $user}
$logontests += @{"PC" = $pc}

#19.1.2	One user can’t logon
$pcnet = Get-WmiObject –Class Win32_NetworkAdapterConfiguration –Filter "IPEnabled=$true" –ComputerName $pc  

$network = [ordered]@{
IPAddress = $pcnet.IPAddress
IPSubnet = $pcnet.IPSubnet
DefaultIPGateway = $pcnet.DefaultIPGateway
DNSServerSearchOrder = $pcnet.DNSServerSearchOrder
DHCPEnabled = $pcnet.DHCPEnabled
}

$logontests += $network

#19.1.3	Logon scripts
#FIRST TEST: CHECK LOGON SCRIPT SETTINGS IN AD

$path = $null
$path = Get-ADUser –Identity $user –Properties scriptpath
if ($path.ScriptPath) 
{
  $logontests += @{'LogonScriptPath' = $path.ScriptPath}
}
else
{
  $logontests += @{'LogonScriptPath' = 'Not Set'}
}

#SECOND TEST: CHECK LOGON SCRIPT EXISTS
$pathtest = $null
if ($path.ScriptPath) 
{
  $domain = (Get-ADDomain).DNSRoot
  $pathtest = Test-Path -Path (Join-Path -Path "\\$dc\sysvol\$domain\scripts" -ChildPath $path.ScriptPath)
}
if ($pathtest) 
{
  $logontests += @{'LogonScriptExists' = $true}
}
else
{
  $logontests += @{'LogonScriptExists' = $false}
}

#TEST THE WORKSTATIONS A USER CAN LOGON
$ws = (Get-ADUser -Identity $user -Properties userWorkstations).userWorkstations -split ","
$pclogon = $ws -contains $pc

if ($ws[0] -ne "")
{
  if ($pclogon)
  { 
    $logontests += @{"CanLogonTo_$pc" = $true}
  }
  else
  { 
    $logontests += @{"CanLogonTo_$pc" = $false}
  }
}
else
{
  $logontests += @{"CanLogonTo_$pc" = $true}
}

#TEST THE AMOUNT OF TIME A USER CAN BE LOGGED IN FOR
# get an array of values - one per day 
# 24 hours - 1 = can logon; 0 = can't
# no values means can logon 24 x 7 hours (default)
$power2 = @(1,2,4,8,16,32,64,128)
$onoff = @("0", "1")
$days = 0..6 | foreach {([System.DayOfWeek]$psitem).ToString()}
$day = 0
$logonhours = @()


$bytes = (Get-ADUser -Identity $user -Properties logonHours).logonHours


for ($i=0; $i -lt $bytes.Length; $i+=3){
  $logonhours += "$(($days[$day]).SubString(0,3)): $(convertTO-LogonHours $bytes[$i]) $(convertTO-LogonHours $bytes[$i+1]) $(convertTO-LogonHours $bytes[$i+2])"
  $day ++
}

$logontests += @{'LogonHours' = $logonhours}

##
## TEST DNS records
## may need to change or parameterize the site name
if ($testdns)
{
  
  $zone = "_msdcs.$domain"
  $srvs = Get-DnsServerResourceRecord -ZoneName $zone -ComputerName $dc -RRType SRV |    
  where HostName -like "*Site1*"  | select Hostname, RecordType, Timestamp, TimeToLive, RecordData
   
  $logontests += @{'SRVrecords' = $($srvs)}
}

New-Object -TypeName PSObject -Property $logontests
}

test-userlogon -user jgreen -pc server03 -dc server02 -testdns