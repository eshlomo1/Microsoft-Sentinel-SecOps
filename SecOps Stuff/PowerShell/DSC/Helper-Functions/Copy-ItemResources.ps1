$From = (Get-ChildItem -Path ${env:ProgramFiles}\WindowsPowerShell\Modules\x*).fullname
$To =  "${env:ProgramFiles}\WindowsPowerShell\Modules"
 
$session = New-PSSession -ComputerName DSC  -Credential zephyr\administrator
 
Copy-Item -Path $From -Recurse -Destination $To -ToSession $session -Verbose