$Catalog = GC "C:\test\dp.txt"
ForEach($Machine in $Catalog) 
{$QueryString = Gwmi Win32_OperatingSystem -Comp $Machine 
$QueryString = $QueryString.Caption 
Write-Host $QueryString}
