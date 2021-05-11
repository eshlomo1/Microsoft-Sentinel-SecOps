## Ways to Load the SMO SQL Server Assembly

## Load the .NET assembly for PowerShell 1.0 (can also be used with PowerShell 2.0 and later).
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");

## Load the .NET assembly for PowerShell 2.0 or later (but can break in some situations).
Add-Type -Assemblyname "Microsoft.SqlServer.Smo";

## Load the .NET assembly for PowerShell 2.0 or later.
Add-Type -path `
"C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\10.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll";



## Listing 1: Script to Retrieve Specific Information from All SQL Server Instances

## Load the .NET assembly.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");

## Build the list of SQL Server instances.
$SQLSvr = `
[Microsoft.SqlServer.Management.Smo.SmoApplication]::EnumAvailableSqlServers($false) | Select name;
$SQLSvr;

## For each SQL Server instance, display some information.
foreach($svr in $SQLSvr)
{
  ## Build the SQL Server .NET object.
  $MySQLObject = `
    new-object Microsoft.SqlServer.Management.Smo.Server `
    $svr.Name;

  ## Work with SMO and the databases.
  $MySQLObject.Information | `
      Select Parent, Product, Edition, VersionString `
      | FT -auto;
};



## Listing 2: Script to Retrieve Specific Information from the Listed SQL Server Instances

## Load the .NET assembly.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;

## Provide the list of SQL Server names. (Need to replace with your server names.)
$SQLSvr = "SQL01","SQL02","SQL03";

## For each SQL Server instance, display some information and
## save it in a PowerShell variable.
$Results = $null;
$Results = foreach($svr in $SQLSvr)
{
  ## Build the SQL Server .NET object.
  $MySQLObject = `
    new-object Microsoft.SqlServer.Management.Smo.Server `
    $svr;

  ## Work with SMO and the databases.
  $MySQLObject.Information | `
      Select Parent, Product, Edition, VersionString;
}; 
## Display the results on screen.
$Results | ft -autosize;



## Listing 3: Script to Retrieve the Owner, Recovery Model, and Status of Each Database

## Load the .NET assembly.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;

## Build the list of SQL Server names.
$MySQLObject = `
  new-object Microsoft.SqlServer.Management.Smo.Server `
  "SQL01";

$MySQLObject.databases `
  | Select parent, name, Owner, `
    RecoveryModel, Status | FT -AutoSize;


## Listing 4: Script to Retrieve Basic Information About SQL Server Agent Jobs

## Load the .NET assembly.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;

## Build the list of SQL Server names.
$MySQLObject = `
  new-object Microsoft.SqlServer.Management.Smo.Server `
  "SQL01";

($MySQLObject.JobServer.jobs) `
    | Select  Parent, Name, isEnabled, `
      lastRunDate, lastRunOutCome `
    | ft -Auto;



