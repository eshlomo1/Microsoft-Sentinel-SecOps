#$path = 'C:\Users\duffney\Dropbox\josh-duffney\regular-expression-introduction\regular-expression-introduction-m1\regular-expression-introduction-m1-01.mp4'

$Files = (Get-ChildItem -Path 'C:\Users\duffney\Dropbox\josh-duffney\regular-expression-introduction\*.mp4' -Recurse | where fullname -NotMatch 'old').fullname
#$files = (Get-ChildItem -Path 'C:\Users\duffney\Dropbox\josh-duffney\regular-expression-introduction\regular-expression-introduction-m6\*.mp4' -Recurse | where fullname -NotMatch 'old').fullname
$totaltime = $null

foreach ($file in $Files){

$shell = New-Object -COMObject Shell.Application
$folder = Split-Path $file
$file = Split-Path $file -Leaf
$shellfolder = $shell.Namespace($folder)
$shellfile = $shellfolder.ParseName($file)

#write-host $shellfolder.GetDetailsOf($shellfile, 27); 

$time = $shellfolder.GetDetailsOf($shellfile, 27) -replace  '(\d+:0?)?([^0])','$2'
$time = $time -replace ':','.'
$time = [math]::round($time,2)

Write-Host $time -ForegroundColor Green
Write-Host $file -ForegroundColor red

$totaltime += $time

}

$totaltime

#$time = '4:07'
#$timearry = $time.Split(':')
#
#$totaltime += New-TimeSpan -Minutes $timearry[0]
#$totaltime += New-TimeSpan -Seconds $timearry[1]