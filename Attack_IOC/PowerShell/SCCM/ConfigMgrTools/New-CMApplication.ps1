# ---------------------------------------------------
# Version: 6.0
# Author: Joshua Duffney
# Date: 07/29/2014
# Description: Using PowerShell to create an SCCM Application from information in a .csv file.
# Sources: http://pluralsight.com/training/courses/TableOfContents?courseName=planning-creating-applications-sccm-2012&highlight, http://dexterposh.blogspot.ca/
# ---------------------------------------------------


Function NewCMApplication {


Param(
    [string]$SiteServerName,
    [string]$SiteCode,
    [string]$SharedContentFolder
)


    ## Declare Variables
    $ErrorActionPreference = "stop"
    $Owner = $pkg.Owner
    $SupportContact = $pkg.SupportContact
    $Publisher = $pkg.Publisher
    $ApplicationName = $pkg.Name
    $ApplicationFullName = $pkg.Publisher + $pkg.Name + $pkg.SoftwareVersion
    $SoftwareVersion = $pkg.SoftwareVersion
    $InstallationProgram = $pkg.InstallationProgram
    $SourceFolderPath = $pkg.SourceFolderPath
    $ContentLocation = $ApplicationSourceContent
    $EstimatedInstallationTimeMinutes = $pkg.EstimatedInstallationTimeMinutes
    $MaximumAllowedRunTimeMinutes = [int]$EstimatedInstallationTimeMinutes *6
    $ScriptType = "PowerShell"
    $ScriptContent = "if ( (GET-WMIOBJECT win32_product).name -eq '$ApplicationName' ) { $true }"
    $IconLocation = $SourceFolderPath+ '\' + $ApplicationName + '.ico'
    $ApplicationFolder = $pkg.Publisher
    $CatalogCategory = $pkg.CatalogCategory
    $ApplicationSourceContent = "$($Publisher)_$($ApplicationName)_$($SoftwareVersion)".Replace(' ','_')
    $ApplicationSourceContent = "$SharedContentFolder\$ApplicationSourceContent"


        #Determine Silent or User Interactive installation
        if (($InstallationProgram -match "/S") -or ($InstallationProgram -match "/Q")) { 
        $InstallationBehaviorType = "InstallforSystem"; $InstallationProgramVisibility = "Hidden"; $DeploymentTypeName = $ApplicationName + " " + "Install Silent"; $LogonRequirementType = "WhetherOrNotUserLoggedOn";$Silent = $true
        } else {
        $InstallationBehaviorType = "InstallforUser"; $InstallationProgramVisibility = "Normal"; $DeploymentTypeName = $ApplicationName + " " + "Install";$Silent = $false
        }


    #DeploymentType Hashtables (Hashtables used due to errors caused by $true values in variables and objects)
    $AddCMDeploymentTypeParamsSilent = @{
    'ApplicationName' = $ApplicationFullName;
    'DeploymentTypeName' = $DeploymentTypeName;
    'ScriptInstaller' = $true;
    'ManualSpecifyDeploymentType' = $true;
    'InstallationProgram' = $InstallationProgram;
    'ContentLocation' = $ApplicationSourceContent;
    'InstallationBehaviorType' = $InstallationBehaviorType;
    'InstallationProgramVisibility' = $InstallationProgramVisibility;
    'MaximumAllowedRunTimeMinutes' = $MaximumAllowedRunTimeMinutes;
    'EstimatedInstallationTimeMinutes' = $EstimatedInstallationTimeMinutes;
    'DetectDeploymentTypeByCustomScript' = $true;
    'ScriptType' = $ScriptType;
    'ScriptContent' = $ScriptContent;
    'LogonRequirementType' = $LogonRequirementType;
    }

     $AddCMDeploymentTypeParams = @{
    'ApplicationName' = $ApplicationFullName;
    'DeploymentTypeName' = $DeploymentTypeName;
    'ScriptInstaller' = $true;
    'ManualSpecifyDeploymentType' = $true;
    'InstallationProgram' = $InstallationProgram;
    'ContentLocation' = $ApplicationSourceContent;
    'InstallationBehaviorType' = $InstallationBehaviorType;
    'InstallationProgramVisibility' = $InstallationProgramVisibility;
    'MaximumAllowedRunTimeMinutes' = $MaximumAllowedRunTimeMinutes;
    'EstimatedInstallationTimeMinutes' = $EstimatedInstallationTimeMinutes;
    'DetectDeploymentTypeByCustomScript' = $true;
    'ScriptType' = $ScriptType;
    'ScriptContent' = $ScriptContent;
    }



    ## Create the shared content folder for the Package
     Try
     {
     Set-Location $env:SystemRoot
     mkdir $ApplicationSourceContent -ErrorAction Stop
     Copy-Item $SourceFolderPath\* $ApplicationSourceContent -Recurse -Force
     }
     Catch [System.IO.IOException]
     {
        write-host "$ApplicationSourceContent already exists" -ErrorAction SilentlyContinue
     }
     Catch
     {
         $ErrorMessage = $_.Exception.Message
         $FailedItem = $_.Exception.ItemName
     }   


    ## Import SCCM Console Module
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




    ## Create the application container. This will hold our deployment type.
    Try
    {
    if (!(Test-Path $IconLocation)) {
    New-CMApplication -Name $ApplicationFullName -Owner $Owner -SupportContact $SupportContact -Publisher $Publisher -SoftwareVersion $SoftwareVersion -ErrorAction Stop | Out-Null
    } else {
    New-CMApplication -Name $ApplicationFullName -Owner $Owner -SupportContact $SupportContact -IconLocationFile $IconLocation -Publisher $Publisher -SoftwareVersion $SoftwareVersion -ErrorAction Stop | Out-Null
    }
    }
    Catch [System.ArgumentException]
    {
            "$ApplicationFullName already exists"
    }
    Catch
    {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
    }


    ## Create the deployment type.
    Try
    {
        if ($Silent -eq $false){
        Add-CMDeploymentType @AddCMDeploymentTypeParams -ErrorAction Stop | Out-Null
        } Else {
        Add-CMDeploymentType @AddCMDeploymentTypeParamsSilent -ErrorAction Stop | Out-Null
        }
    }
    Catch
    {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
    }


    ## Create SCCM Vendor Folder and Move New Application
    $CMApplication = Get-CMApplication -Name $ApplicationFullName
    Set-Location .\Application
    $VendorFolders = (get-childitem).Name
       
    Try
    {
        New-Item -Name $ApplicationFolder
        Move-CMObject -FolderPath $ApplicationFolder -InputObject $CMApplication -ErrorAction Stop | Out-Null
        cd ..
    }
    Catch [System.InvalidOperationException]
    {
        Move-CMObject -FolderPath $ApplicationFolder -InputObject $CMApplication -ErrorAction Stop | Out-Null
        cd ..
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }


    ## Set DistributionPointSettings
    Try
    {
        $AppliactionID = (Get-CMApplication -name $ApplicationFullName).CI_ID
        Set-CMApplication -Id $AppliactionID -DistributionPointSetting AutoDownload
    }
    Catch [System.Management.Automation.ItemNotFoundException]
    {
        "No Applications found with $ApplicationID"
    }
    Catch
    {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
    }




    ## Set CatalogCategory
    Try
    {
        $AppliactionID = (Get-CMApplication -name $ApplicationFullName).CI_ID
        Set-CMApplication -Id $AppliactionID -UserCategories $CatalogCategory
    }
    Catch [System.Management.Automation.ItemNotFoundException]
    {
        "No Applications found with $ApplicationID"
    }
    Catch
    {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
    }


}

$pkgs = Import-Csv "c:\scripts\testing.csv"

foreach($pkg in $pkgs)
{
NewCMApplication -SiteServerName Server -SiteCode SiteCode -SharedContentFolder "\\server\source"
}
