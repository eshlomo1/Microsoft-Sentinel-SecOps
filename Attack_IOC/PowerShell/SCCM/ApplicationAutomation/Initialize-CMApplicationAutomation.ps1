Function Initialize-CMApplicationAutomation {
<#
.SYNOPSIS
    Fully Automates ConfigMgr Application Creation with PADT
.DESCRIPTION

.PARAMETER 

.EXAMPLE

.Notes

.LINK

#>

[CmdletBinding()]
	
	param (
	[string]$Vendor,
    [string]$Name,
    [string]$Version,
    [string[]]$InstallFile,
    [string[]]$InstallString,
    [string[]]$InstallFilex64,
    [string[]]$InstallStringx64,
    [string]$EstimatedTime,
    [string]$Owner,
    [string]$SupportContact,
    [string]$CloseApps,
    [string]$SourceFolderPath,
    [string]$DestinationContentFolder,
    [string]$CatalogCategory,
    [string]$DeploymentMode,
    [string]$DistributionPointGroupName,
    [string]$ModifiedPADT,
    [string]$SiteCode,
    [string]$PADTFiles,
    [string]$InstallationBehaviorType
	)

Begin {
	
        Import-Module ConfigMgrApplicationAutomation
        $ApplicationSourceFolder = "$($Vendor)_$($Name)_$($Version)".Replace(' ','_')
        $ApplicationSourceContent = $($DestinationContentFolder) + "\" + "$($Vendor)_$($Name)_$($Version)".Replace(' ','_')
        $ScriptOutLocation = $ApplicationSourceContent

    }
	
Process {
	
        $ContentSourceParams = @{
        'PADTFiles' = $PADTFiles;
        'ApplicationSourceContent' = $ApplicationSourceContent;
        'SourceFolderPath' = $SourceFolderPath
        } 
        
        New-ContentSource @ContentSourceParams -Verbose

        $WritePADTparams = @{
        'Vendor' = $Vendor;
        'Name'  = $Name;
        'Version' = $Version;
        'InstallFile' = $InstallFile;
        'InstallString' = $InstallString;
        'InstallFilex64' = $InstallFilex64;
        'InstallStringx64' = $InstallStringx64;
        'CloseApps' = $CloseApps;
        'SourceFolderPath' = $SourceFolderPath;
        'ModifiedPADT' = $ModifiedPADT;
        'ScriptOutLocation' = $ApplicationSourceContent
        }
        
        Write-PADT @WritePADTparams -Verbose | Out-Null
        
        Enter-CMSession -SiteCode $SiteCode -Verbose
        
        $ConfigMgrAppParams = @{
        'Publisher' = $Vendor
        'Name'  = $Name
        'SoftwareVersion' = $Version
        'Owner' = $Owner
        'SupportContact' = $SupportContact
        'EstimatedTime' = $EstimatedTime
        'ContentLocation' = $ApplicationSourceContent
        'InstallationBehaviorType' = $InstallationBehaviorType
        'DeploymentMode' = $DeploymentMode
        'CatalogCategory' = $CatalogCategory
        'DistributionPointGroupName' = $DistributionPointGroupName
        }
        
        New-ConfigMgrApplication @ConfigMgrAppParams -Verbose

        
        $CMFolder = @{
        'ApplicationFullName' = $Vendor + " " + $Name + " " + $Version
        'Vendor'= $Vendor
        }
        Set-CMVendorfolder @CMFolder -verbose


    
    
    
    }
	
End {
	}


}
