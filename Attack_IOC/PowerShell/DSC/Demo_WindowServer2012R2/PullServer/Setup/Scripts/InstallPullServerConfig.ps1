#--------------------------------------------------------------------------------------------------------------
# Powershell Script that installs the Pull server configuration and Pull server compliance configuration
#--------------------------------------------------------------------------------------------------------------
[CmdletBinding()]
Param( 
        [Int]$Port = 8080,
        [switch]$DSCServiceSetup,
        [String]$iisroot = "$env:HOMEDRIVE\inetpub\wwwroot",
        [String]$rootdatapath = "$env:PROGRAMDATA"
	 ) 

#
# Source files
#
$pathPullServer     = "$pshome\modules\PSDesiredStateConfiguration\PullServer"

#
# Commands to do the actual installation
#
$scriptDir          = Split-Path $MyInvocation.MyCommand.Path
Import-Module $scriptDir\PSWSIISEndpoint.psm1 -force

#
# Default and calculated values
#
$siteName           = "PSDSCPullServer"
$iisPullServer      = Join-Path $iisroot $siteName
$psdscserverpath    = Join-Path $rootdatapath $siteName

$configurationpath  = Join-Path $psdscserverpath "Configuration"
$modulepath         = Join-Path $psdscserverpath "Modules"

$jet4provider       = "System.Data.OleDb"
$jet4database       = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$env:PROGRAMDATA\PSDSCPullServer\Devices.mdb;"

#
# Install the DSC feature if specified
#
if($DSCServiceSetup)
{
	Add-WindowsFeature Dsc-Service
}

#
# Create the basic pull server endpoint
#
Create-PSWSEndpoint     -site $siteName `
                        -path $iisPullServer `
                        -cfgfile "$pathPullServer\PSDSCPullServer.config" `
                        -port $Port `
                        -applicationPoolIdentityType LocalSystem `
                        -app $siteName `
                        -svc "$pathPullServer\PSDSCPullServer.svc" `
                        -mof "$pathPullServer\PSDSCPullServer.mof" `
                        -dispatch "$pathPullServer\PSDSCPullServer.xml" `
                        -asax "$pathPullServer\Global.asax" `
                        -dependentBinaries  "$pathPullServer\Microsoft.Powershell.DesiredConfig.PullServer.dll"

#
# Create the application data directory calculated above
#
New-Item -path $rootdatapath -itemType "directory" -Force

#
# Set values into the web.config that define the repository and where
# configuration and modules files are stored. Also copy an empty database
# into place.
#
Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "dbprovider" `
                            -value $jet4provider

Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "dbconnectionstr" `
                            -value $jet4database

$repository = Join-Path $rootdatapath "Devices.mdb"
Copy-Item "$pathPullServer\Devices.mdb" $repository -Force

New-Item -path "$configurationpath" -itemType "directory" -Force

Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "ConfigurationPath" `
                            -value $configurationpath

New-Item -path "$modulepath" -itemType "directory" -Force

Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "ModulePath" `
                            -value $modulepath

#
# Used for testing
#
Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "ApplicationBase" `
                            -value $iispullserver

Set-Webconfig-AppSettings `
                            -path $iisPullServer `
                            -key "TestConfigPath" `
                            -value $iispullserver