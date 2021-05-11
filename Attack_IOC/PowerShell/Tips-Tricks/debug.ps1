[CmdletBinding()]
param()
$data = Import-Csv C:\scripts\data.csv
Write-Debug "Imported CSV data"

$totalqty = 0
$totalsold = 0
$totalbought = 0

foreach ($line in $data) {
    if ($line.transaction -eq 'buy') {
        Write-Debug "ENDED BUY transaction (we sold)"
        $totalqty -= $line.qty
        $totalsold = $line.total
    } else {
        Write-Debug "ENDED SELL transaction (we bought)"
        $totalqty += $line.qty
        $totalbought = $line.total
   }
}
Write-Debug "OUTPUT: $totalqty,$totalbought,$totalsold,$($totalbought-$totalsold)" 
"totalqty,totalboght,totalsold,totalamt" | Out-File C:\scripts\summary.csv
"$totalqty,$totalbought,$totalsold,$($totalbought-$totalsold)" | Out-File C:\scripts\summary.csv -Append
