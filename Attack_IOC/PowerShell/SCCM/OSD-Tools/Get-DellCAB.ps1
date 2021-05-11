Function Get-DellCAB {
<#
.SYNOPSIS

Get-DellCAB extracts the .cab file and places them in a 
structure suited for the ImportDrivers.ps1.

.DESCRIPTION

Get-DellCAB will extract Dell driver .CAB files
in a format required for the ImportDrivers script that will
automate driver importing into System Center Configuration
Center.

.PARAMETER CabFilePath

UNC path to the .cab file

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

PS C:\> Get-DellCAB -CabFilePath D:\CABFiles\960-win7-A05-RG8TH.CAB

.EXAMPLE

PS C:\> Get-ChildItem *.cab | Get-DellCAB

.Notes

Driver Sources
Dell - http://en.community.dell.com/techcenter/enterprise-client/w/wiki/2065.dell-driver-cab-files-for-enterprise-client-os-deployment (Direct download of .CAB)

.LINK

DeploymentResearch
http://www.deploymentresearch.com/Research/tabid/62/EntryId/69/The-Drivers-Saga-continues-How-to-Master-Drivers-in-ConfigMgr-2012.aspx
Coretech
http://blog.coretech.dk/kea/automate-importing-and-creating-drivers-packages-in-sccm-2012-r2/
#>
[CmdletBinding()]
Param(
    [Parameter(Position=0,ValueFromPipeline=$True)]
    [ValidateNotNullorEmpty()]
    [Alias('Path')]
    [string[]]$CabFilePath,
    
    [string]$Make = 'Dell',
    
    [string]$Model,
    
    [String]$OperatingSystem,

    [string]$outputFilePath

)

Begin {
    Write-Verbose "Starting Get-DellCab"
}

Process {
    Foreach ($CAB in $CabFilePath) {
        Write-Verbose "Extracting $Cab"
        $CABarray = ((Get-ChildItem -path $CAB).BaseName).split("-")
        $Model = $CABarray[0]
        $OperatingSystem = $CABarray[1]
        Write-Verbose "Model is $Model, OS is $OperatingSystem"
            
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
    }
}
