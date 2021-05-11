configuration HydraFileConfig {

    Import-DscResource -Module xTimeZone

    Node HTTPComputers {


        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'
        }
    }
}

HydraFileConfig -OutputPath C:\DSC\HTTP
$guid=Get-DscLocalConfigurationManager -CimSession HFile01 | Select-Object -ExpandProperty ConfigurationID
# Specify source folder of configuration
$source = "C:\DSC\HTTP\HTTPComputers.mof"
# Destination is the Share on the SMB pull server
$dest = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\$guid.mof"
Copy-Item -Path $source -Destination $dest
#Then on Pull server make checksum
New-DSCChecksum $dest


New-DscCheckSum -ConfigurationPath "C:\Program Files\WindowsPowerShell\DscService\Modules" -OutPath "C:\Program Files\WindowsPowerShell\DscService\Modules" -Verbose -Force
Update-DscConfiguration -ComputerName HFile01 -Wait -Verbose