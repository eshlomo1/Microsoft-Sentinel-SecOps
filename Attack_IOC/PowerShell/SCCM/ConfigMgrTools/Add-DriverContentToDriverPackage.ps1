Function Add-DriverContentToDriverPackage {
<#
.SYNOPSIS

Add a configmgr drivers to driverpackages

.DESCRIPTION

Add a configmgr driver by ID to a driverpackage by name

.PARAMETER SiteCode

SiteCode of the Configuration Manager server

.PARAMETER SiteServer

Name of the configuration manager server

.PARAMETER DriverCI

The CI ID of the driver being added

.PARAMETER DriverPackageName

Name of the Configuration Manager driver package

.EXAMPLE

Add-DriverContentToDriverPackage -SiteCode PRI -SiteServer Server100 -DriverCI 16777351 -DriverPackageName "New Driver Package

.Notes

.LINK

http://cm12sdk.net/?p=933

#>

[CmdLetBinding()]
Param(
[Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Site code")]
            $SiteCode,
[Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Name")]
            $SiteServer,
[Parameter(Mandatory=$True,HelpMessage="Please Enter Driver Name")]
            $DriverCI,
[Parameter(Mandatory=$True,HelpMessage="Please Enter Driver Package Name")]
            $DriverPackageName
        )     
 
    $DriverPackageQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_DriverPackage -ComputerName $SiteServer -Filter "Name='$DriverPackageName'"
    $DriverQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_Driver -ComputerName $SiteServer -Filter "CI_ID='$DriverCI'"
    $DriverContentQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_CIToContent -ComputerName $SiteServer -Filter "CI_ID='$($DriverQuery.CI_ID)'"
 
    $DriverPackageQuery.AddDriverContent($DriverContentQuery.ContentID,$DriverQuery.ContentSourcePath,$False)                         
}
