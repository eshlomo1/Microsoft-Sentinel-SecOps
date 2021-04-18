# ---------------------------------------------------
# Version: 3.0
# Author: Joshua Duffney
# Date: 07/25/2014
# Description: Using PowerShell to create an SCCM Package from information in a .csv file.
# Changesv2: Added error handling with try and catch commands for importing the SCCM module and creation of content directory.
# Changesv3: Added NewCMPackage function
# ---------------------------------------------------
# c:\scripts\CreateSinglePackage.csv

Function NewCMPackage ($Path) {

$obj = Import-Csv "$Path"

$ErrorActionPreference = "stop"
$SiteServerName = 'ServerName'
$SiteCode = 'SiteCode'
$SharedContentFolder = "\\Server\Share\ContentSource"
$SourceFolderPath = $obj.SourceFolder
$Manufacturer = $obj.Manufacturer
$PackageName = $obj.Name
$PackageFullName = $obj.Manufacturer + $obj.Name + $obj.Version
$Version = $obj.Version
$Description = $obj.Description
$CommandLine = $obj.CommandLine
$Language = "English"
$DiskSpaceRequirement = "{0:N2}" -f ((Get-ChildItem -path $SourceFolderPath -recurse | Measure-Object -property length -sum ).sum /1MB)
$DiskSpaceUnit = "MB"
$PackageSourceContent = "$($Manufacturer)_$($PackageName)_$($Version)".Replace(' ','_')
$PackageSourceContent = "$SharedContentFolder\$PackageSourceContent"

    if (($CommandLine -match "/S") -or ($CommandLine -match "/Q")) {
        $ProgramRunType = "WhetherOrNotUserIsLoggedOn";$RunMode = "RunWithAdministrativeRights"; $RunType = "Hidden";$UserInteraction = $False;$StandardProgramName = $obj.Name + " " + "Silent Install"
        } else {
        $ProgramRunType = "WhetherOrNotUserIsLoggedOn";$RunMode = "RunWithAdministrativeRights"; $RunType = "Normal";$UserInteraction = $True;$StandardProgramName = $obj.Name + " " + "Install"
        }

    ## Create the shared content folder for the Package
    Try
    {
    Set-Location $env:SystemRoot
    mkdir $PackageSourceContent -ErrorAction Stop
    Copy-Item $SourceFolderPath\* $PackageSourceContent -Recurse -Force
    }
    Catch [System.IO.IOException]
    {
        Write-Error "$PackageSourceContent already exists"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }

        # Connect to SCCM
    Try
    {
    Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -ErrorAction Stop
    Set-Location "$($SiteCode):"
    }
    Catch [System.IO.FileNotFoundException]
    {
        "SCCM Admin Console not installed"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }
    Finally
    {
        "This Script attempted to import the SCCM module"
    }

## Create the package container.
        New-CMPackage -name $PackageFullName -Description $Description -Language $Language -Manufacturer $Manufacturer -Path $PackageSourceContent -Version $Version | Out-Null

## Create the program. This is the deployment type.
        New-CMProgram -CommandLine $CommandLine -PackageName $PackageFullName -StandardProgramName $StandardProgramName -DiskSpaceRequirement $DiskSpaceRequirement -DiskSpaceUnit $DiskSpaceUnit -ProgramRunType $ProgramRunType -RunMode $RunMode -RunType $RunType -UserInteraction $UserInteraction | Out-Null

}


NewCMPackage "c:\scripts\CreateSinglePackage.csv"
