# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney
# Date: 07/22/2014
# Description: Using PowerShell to create an SCCM Package from information in a .csv file.
# Comments: Reference CreateCMPackage.csv for import headers.
# ---------------------------------------------------

$obj = Import-Csv "c:\scripts\CreateSinglePackage.csv"

$ErrorActionPreference = "stop"
$SiteServerName = 'ServerName'
$SiteCode = 'SiteCode'
$SharedContentFolder = "\\Fileshare"
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

    if (($CommandLine -match "/S") -or ($CommandLine -match "/Q")) {
        $ProgramRunType = "WhetherOrNotUserIsLoggedOn";$RunMode = "RunWithAdministrativeRights"; $RunType = "Hidden";$UserInteraction = $False;$StandardProgramName = $obj.Name + " " + "Silent Install"
        } else {
        $ProgramRunType = "WhetherOrNotUserIsLoggedOn";$RunMode = "RunWithAdministrativeRights"; $RunType = "Normal";$UserInteraction = $True;$StandardProgramName = $obj.Name + " " + "Install"
        }

# Connect to SCCM and existance of Package
if (!(Test-Path "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1")) {
        Write-Error 'Configuration Manager module not found. Is the admin console installed?'
        } elseif (!(Get-Module 'ConfigurationManager')) {
            Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
        }
        Set-Location "$($SiteCode):"

        if (Get-CMPackage -Name $PackageFullName) {
            Write-Error "The application $PackageFullName already exists."
        }
        
        ## Create the shared content folder for the Package
        $PackageSourceContent = "$($Manufacturer)_$($PackageName)_$($Version)".Replace(' ','_')
        $PackageSourceContent = "$SharedContentFolder\$PackageSourceContent"
        if (!(Test-Path $PackageSourceContent)) {
            Set-Location $env:SystemRoot
            mkdir $PackageSourceContent | Out-Null
        } else {
            Write-Host "The path $PackageSourceContent already exists"
        }
        Copy-Item $SourceFolderPath\* $PackageSourceContent -Recurse -Force
        Write-Host -ForegroundColor green "$PackageName directory created"
        


## Create the package container.
        Set-Location "$($SiteCode):"
        New-CMPackage -name $PackageFullName -Description $Description -Language $Language -Manufacturer $Manufacturer -Path $PackageSourceContent -Version $Version | Out-Null

## Create the program. This is the deployment type.
        Set-Location "$($SiteCode):"
        New-CMProgram -CommandLine $CommandLine -PackageName $PackageFullName -StandardProgramName $StandardProgramName -DiskSpaceRequirement $DiskSpaceRequirement -DiskSpaceUnit $DiskSpaceUnit -ProgramRunType $ProgramRunType -RunMode $RunMode -RunType $RunType -UserInteraction $UserInteraction | Out-Null
