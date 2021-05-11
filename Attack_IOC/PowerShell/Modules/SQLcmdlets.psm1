function Get-DatabaseData {
<#
.SYNOPSIS
Executes a query statement against a SQL database table.
.DESCRIPTION
Executes a SQL query statement against a SQL database to retreive information specified by the
query parameter.
.PARAMETER connectionString
Specifies a trust or untrusted string to connect to a SQL database
.PARAMETER query
Specifies a query statement to SQL
.EXAMPLE
Get-DatabaseData -ConnectString 'server=SQL01\SQLEXPRESS;database=OmahaPSUG;trusted_connection=true' -query 'select * from Computers'
.EXAMPLE
Get-DatabaseData -ConnectString 'server=SQL01\SQLEXPRESS;database=OmahaPSUG;trusted_connection=true' `
-query 'select OperatingSystem Where ComputerName = 'PC01'
#>
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query
    )

    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command

    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset)
    $dataset.Tables[0]
    $connection.close()
}

function Invoke-DatabaseQuery {
<#
.SYNOPSIS
Executes a nonquery statement against a SQL database table.
.DESCRIPTION
Executes a SQL nonquery statement against a SQL database to insert or update information 
specified by the query parameter.
.PARAMETER connectionString
Specifies a trust or untrusted string to connect to a SQL database
.PARAMETER query
Specifies a nonquery statement to SQL
.EXAMPLE
Invoke-DatabaseData -ConnectString 'server=SQL01\SQLEXPRESS;database=OmahaPSUG;trusted_connection=true' -query "Insert Into Computers ('ComputerName') Values ('PC01')"
.EXAMPLE
Invoke-DatabaseData -ConnectString 'server=SQL01\SQLEXPRESS;database=OmahaPSUG;trusted_connection=true' -query "Insert Into Computers ('ComputerName','OperatingSystem') Values ('PC01','Win10')"
#>
    [CmdletBinding(SupportsShouldProcess=$True,
                   ConfirmImpact='Low')]
    param (
        [string]$connectionString,
        [string]$query
    )

    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection

    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery()
        $connection.close()
    }
}
