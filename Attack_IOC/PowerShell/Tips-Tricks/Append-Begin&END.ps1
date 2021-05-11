$Lines = Get-Content .\AMDisabledComputers.txt
$OutputPath = "C:\scripts\AMDisabledComputers.csv"
foreach ($Line in $Lines) {
    $Line = $line.Insert(0,'"')
    $Line += '"'
    Write-Host $Line -ForegroundColor Green
    Write-Output $Line | Out-File $OutputPath -Append
}
