$DriverPacks = (Get-CMDriverPackage | Where-Object PackageSize -EQ "0").PackageID
$SiteCode = 'SiteCode'
$CMServer = 'Server'

Function Add-DriverContentToDriverPackage
{
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



Foreach ($DriverPack in $DriverPacks) {

$DriverPackSize = (Get-CMDriverPackage -Id $DriverPack).PackageSize
Write-Host $DriverPackSize -ForegroundColor Green

$Drivers = (Get-CMDriver -DriverPackageId $DriverPack).CI_ID
$Driver = $Drivers[2]
Write-host $Driver -ForegroundColor Green

$DriverPackName = (Get-CMDriverPackage -Id $DriverPack).Name
Write-Host $DriverPackName -ForegroundColor Green

Write-Host "Removing $Driver from $DriverPackName..." -ForegroundColor Green
Remove-CMDriverFromDriverPackage -DriverId $Driver -DriverPackageId $DriverPack -Force -Confirm:$false

Write-Host "Adding $Driver from $DriverPackName..." -ForegroundColor Green
Add-DriverContentToDriverPackage -SiteCode $SiteCode -SiteServer $CMServer -DriverCI $Driver -DriverPackageName $DriverPackName

$DriverPackSize = (Get-CMDriverPackage -Id $DriverPack).PackageSize
Write-host $DriverPackSize -ForegroundColor Green

}
