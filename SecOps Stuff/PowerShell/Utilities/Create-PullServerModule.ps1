$source = "C:\Program Files\WindowsPowerShell\Modules\xTimeZone"

$destination = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\"

$Version = (Get-ChildItem -Path $source -Depth 1).Name[0]
$ResoureName = (Get-ChildItem -Path $source -Depth 1).Parent.Name[0]
$ModuleName = $ResoureName+'_'+$Version

New-Item -Path ($destination+'\'+$ModuleName) -ItemType Directory

Get-ChildItem ($source+'\'+$Version) | Copy-Item -Destination ($destination+'\'+$ModuleName) -Recurse

$destinationZip = ($destination+'\'+$ModuleName)+'.zip'



 If(Test-path $destinationZip) {Remove-item $destinationZip -Force}

Add-Type -assembly "system.io.compression.filesystem"

[io.compression.zipfile]::CreateFromDirectory(($destination+'\'+$ModuleName), $destinationZip)

Remove-Item -Path ($destination+'\'+$ModuleName) -Force

New-DscCheckSum -ConfigurationPath $destinationZip -OutPath $destination -Verbose -Force
