#start-job -scriptblock $scriptblock -RunAs32﻿﻿

$scriptblock = { if($env:Processor_Architecture -eq "x86"){write "running on 32bit"}else{write "running on 64bit"} } 


$sess = New-PSSession -computername admt01 -ConfigurationName microsoft.powershell32

Invoke-Command -Session $sess -ScriptBlock $scriptblock