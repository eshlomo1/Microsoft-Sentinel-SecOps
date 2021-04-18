Function Get-CABfiles {
<#
.SYNOPSIS

Get-CABfiles extracts the .cab file and places them in a 
structure suited for the ImportDrivers.ps1.

.DESCRIPTION

Get-CABfiles will extract Dell,HP, and Lenovo driver .CAB files
in a format required for the ImportDrivers script that will
automate driver importing into System Center Configuration
Center.

.PARAMETER CabFilePath

UNC path to the .cab file, must specify the full path to 
the .CAB file.

.PARAMETER Make

Defines the make of the machine that the cab file
has drivers for.

.PARAMETER Model

Defines the model of the machine that the cab file has
drivers for.

.PARAMETER OperatingSystem

Specifies the operating system type such as Windows 7
Windows 8.

.PARAMETER OperatingSystemType

Specifies the type of OS such as x64 or x86.

.PARAMETER outputFilePath

Determines the output directory of the drivers in the
folder and naming standards necessary for the 
ImportDrivers.ps1.

.EXAMPLE

Get-CABfiles -CabFilePath c:\CABsource -Make HP -Model ZBook17 -outputFilePath "C:\CABExtracts"

.Notes

Driver Sources by Vendor
Lenovo - http://support.lenovo.com/us/en/documents/ht037099#ur (Update Retriever Download)
HP - http://www8.hp.com/us/en/ads/clientmanagement/drivers-bios.html?jumpid=va_r11260_go_clientmanagement_sdm#softpaq-download-mng (HP SoftPaq Download)
Dell - http://en.community.dell.com/techcenter/enterprise-client/w/wiki/2065.dell-driver-cab-files-for-enterprise-client-os-deployment (Direct download of .CAB)

.LINK

DeploymentResearch
http://www.deploymentresearch.com/Research/tabid/62/EntryId/69/The-Drivers-Saga-continues-How-to-Master-Drivers-in-ConfigMgr-2012.aspx
Coretech
http://blog.coretech.dk/kea/automate-importing-and-creating-drivers-packages-in-sccm-2012-r2/
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,HelpMessage="Enter the location of the .CAB file")]
    [Alias('Path')]
    [string]$CabFilePath,
    
    [Parameter(Mandatory=$True)]
    [ValidateSet("Dell","HP","Lenovo")]
    [string]$Make,
    
    [Parameter(Mandatory=$True)]
    [string]$Model,
    
    [Parameter(Mandatory=$True)]
    [ValidateSet("Win7","Win8.1")]
    [String]$OperatingSystem,
    
    [Parameter(Mandatory=$True)]
    [ValidateSet("x64","x86","Both")]
    [String]$OperatingSystemType,

    [Parameter(Mandatory=$True)]
    [string]$outputFilePath

)

Switch ($Make) {

    "Dell"
        {

            $CABarray = ((Get-ChildItem -path $CabFilePath *.cab).BaseName).split("-")
            $Model = $CABarray[0]
            $OperatingSystem = $CABarray[1]
            
            if ($OperatingSystem -eq "Win7") {
            $x64filepath = $outputFilePath + "\" + $Model +"\" +"win7" +"\" + "x64"
            $x86filepath = $outputFilePath + "\" + $Model +"\" +"win7" +"\" + "x86"
            $DrivePackageX64 = "$outputFilePath\$Make\$Model\Win7x64"
            $DrivePackageX86 = "$outputFilePath\$Make\$Model\Win7x86"
            } elseif ($OperatingSystem -eq "Win8.1") {
            $x64filepath = $outputFilePath + "\" + $Model +"\" +"win8.1" +"\" + "x64"
            $x86filepath = $outputFilePath + "\" + $Model +"\" +"win8.1" +"\" + "x86"
            $DrivePackageX64 = "$outputFilePath\$Make\$Model\Win8.1x64"
            $DrivePackageX86 = "$outputFilePath\$Make\$Model\Win8.1x86"
            }
            

            
            Try
                {
                    #Set-Location $env:SystemRoot
                    Get-ChildItem $CabFilePath | % {& "C:\Program Files\7-Zip\7z.exe" "x" $_.fullname "-o$outputFilePath"} -ErrorAction Stop
                    Copy-Item -path $x64filepath -Destination $DrivePackageX64 -Recurse -Force
                    Copy-Item -path $x86filepath -Destination $DrivePackageX86 -Recurse -Force
                    Remove-Item -Path $outputFilePath\$Model -Force -Recurse
                }
                Catch [System.IO.IOException]
                {
                    Write-Error "$outputFilePath already exists"
                }
                Catch
                {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                }
            
            }
      "HP"
          {

            $filepath = $outputFilePath + "\" + ((Get-ChildItem -Path $CabFilePath *.cab).BaseName)
            $DrivePackage = "$outputFilePath\$Make\$Model\$OperatingSystem$OperatingSystemType"

            
            Try
                {
                #Set-Location $env:SystemRoot
                Get-ChildItem $CabFilePath | % {& "C:\Program Files\7-Zip\7z.exe" "x" $_.fullname "-o$filepath"} -ErrorAction Stop
                Copy-Item -path $filepath -Destination $DrivePackage -Recurse -Force
                Remove-Item -Path $filepath -Force -Recurse
                }
                Catch [System.IO.IOException]
                {
                    Write-Error "$outputFilePath already exists"
                }
                Catch
                {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                }

         }
      
      "Lenovo"
            {


            #--Work In Progress.....


            }

}

}
