class SQLString {
    
    [string]$Database
    [string]$ServerName
    [string]$ConnectionString
    [string]$Query
    [string]$Columns
    [object]$Values

    SQLString([String]$Database,[String]$ServerName){
        $This.ConnectionString = "server=$($ServerName);database=$($Database);trusted_connection=True"

    }

    [void] SelectQuery($Column,$Table)
    {
        $This.Query = "Select $Column From $Table"
    }

    [void] InsertUserQuery($Table,$Values)
    {        
        $This.Columns = (Get-DatabaseData -connectionString $this.ConnectionString -query "SELECT COLUMN_NAME FROM $($Table_Name).information_schema.columns WHERE  table_name = '$($Table)' ORDER  BY ORDINAL_POSITION" -isSQLServer).Column_Name
        $This.Columns = $This.Columns.Replace(" ",",")
        $Test = $this.Columns.Split(",")
        
        foreach ($t in $test){
            $This.Values += "'"+ (Get-ADUser -Identity $Values -Properties $t).$t +"'"+','
            #$this.Values += "'"+$($t)+"'"+','
        }
        $This.Values = $this.Values -replace ".$"
        
        $This.Query = "INSERT INTO $Table ($($This.Columns)) VALUES  ($($This.Values))"
    }

}
$2 = [SQLString]::New('Database','ServerName\SQLInstance')
$2.InsertUserQuery('Table_Name','UserName')
$2
