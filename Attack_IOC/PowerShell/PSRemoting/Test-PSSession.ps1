$scriptblock = { if($env:Processor_Architecture -eq "x86"){write "32bit"}else{write "64bit"} } 
$scriptblock1 = {$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$secprin = New-Object Security.Principal.WindowsPrincipal $currentUser #2

if ($secprin.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{$admin = 'Administrator'}
else {$admin = 'non-Administrator'};$admin; if($env:Processor_Architecture -eq "x86"){write "32bit"}else{write "64bit"}}