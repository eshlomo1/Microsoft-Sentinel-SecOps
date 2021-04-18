[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");
#Add-Type -AssemblyName "Microsoft.SqlServer.Smo"
#Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\10.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"


$SQLSvr = 'SQL01\SQLEXPRESS'
$MySQLObject = new-object Microsoft.SqlServer.Management.Smo.Server $SQLSvr
#$SQLSvr = [Microsoft.SqlServer.Management.Smo.SmoApplication]::EnumAvailableSqlServers($false) | Select name;
#$SQLSvr;
$MySQLObject | gm | more