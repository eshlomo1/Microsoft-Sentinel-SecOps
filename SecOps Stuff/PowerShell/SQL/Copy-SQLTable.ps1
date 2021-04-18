function Copy-SQLTable {
<#
.SYNOPSIS
Copies a table from a source database and inserts it into the target database.
.DESCRIPTION
Takes all the data from the source database and inserts it into the target database with the same name.
.PARAMETER TableName
Specifies the table name to be copied from the source and inserted into the target.
.PARAMETER SourceServer
Specifies source server DNS name and instance, use ServerName\InstanceName.
.PARAMETER SourceDataBase
Specifies the source database name.
.PARAMETER TargetDatabase
Specifies the target database name.
.PARAMETER TargetServer
SPecifies the target server DNS name and instance, user ServerName\InstanceName.
.EXAMPLE
Copy-SQLTable -TableName 'OmahaPSUG_Computers' -SourceServer 'SQL01\SQLEXPRESS' -SourceDataBase 'OmahaPSUG' -TargetDatabase 'OmahaPSUG_BK' -TargetServer 'SQL01\SQLEXPRESS'
#>
[CmdletBinding()]

Param(

[string]$TableName,

[string]$SourceServer,

[string]$SourceDataBase,

[string]$TargetServer,

[string]$TargetDatabase
)


$SourceConnectionString = "server=$SourceServer;database=$SourceDataBase;trusted_connection=true"
$TargetConnectionString = "server=$TargetServer;database=$TargetDatabase;trusted_connection=true"

$Data = Get-DatabaseData -connectionString $SourceConnectionString -query "Select * from $TableName"
$Data = $Data[1..($Data.Count)]

$Columns = (Get-DatabaseData -connectionString $SourceConnectionString -query "SELECT COLUMN_NAME FROM $SourceDataBase.information_schema.columns WHERE  table_name = '$TableName' ORDER  BY ORDINAL_POSITION").Column_Name

    foreach ($c in $Columns){$InsertColumns += $c+','}

$InsertColumns=$InsertColumns.Trim(',')

    Foreach ($Value in $Data) {

            $array = $Value.ItemArray
            foreach ($a in $array){
                $values += "'"+$a+"'"+','
            }
            $Values = $Values.Trim(',')
            $query = "Insert Into $TableName ($InsertColumns) Values ($Values)"
            $Values = $null


        Invoke-DatabaseQuery -connectionString $TargetConnectionString -query $query
    }
}
