$Computer = 'HCD01'

Get-DscResource | 
where path -match "c:\\Program Files\\WindowsPowerShell\\Modules" |
Select -expandProperty Module -Unique | 
foreach {
 $out = "{0}_{1}.zip" -f $_.Name,$_.Version
 $zip = Join-Path -path "C:\Program Files\WindowsPowerShell\DscService\Modules" -ChildPath $out
 New-ZipArchive -path $_.ModuleBase -OutputPath $zip -Passthru
 #give file a chance to close
 start-sleep -Seconds 1 
 If (Test-Path $zip) {
    Try {
        New-DSCCheckSum -ConfigurationPath $zip -ErrorAction Stop
    }
    Catch {
        Write-Warning "Failed to create checksum for $zip"
    }
 }
 else {
    Write-Warning "Failed to find $zip"
 }
 
}