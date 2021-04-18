Function Create-ConfigMgrApplication {
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

.Notes

.LINK

#>

[CmdletBinding()]
	
	param (
	[string]$Name,
    [string]$Owner,
    [string]$SupportContact,
    [string]$Publisher,
    [string]$SoftwareVersion,
    [string]$EstimatedTime,
    [string]$ContentLocation,
    [string]$InstallationBehaviorType,
    [string]$DeploymentMode,
    [string]$CatalogCategory,
    [string]$DistributionPointGroupName
	)

Begin {

        if ((Get-Location).Provider.Name -ne 'CMSite') { Write-Error -Message "Not Connected to a CMSite PSDrive" -ErrorAction Stop }
        
        $ApplicationFullName = $Publisher + " " + $Name + " " + $SoftwareVersion
        $AppliactionID = (Get-CMApplication -name $ApplicationFullName).CI_ID


        Switch ($DeploymentMode) {
    
            "Silent" {

                    $AddCMDeploymentTypeParams = @{
                        'ApplicationName' = $ApplicationFullName;
                        'DeploymentTypeName' = $Name + " " + 'Install Silent';
                        'ScriptInstaller' = $true;
                        'ManualSpecifyDeploymentType' = $true;
                        'InstallationProgram' = 'Deploy-Application.EXE -DeployMode Silent';
                        'UninstallProgram' = 'Deploy-Application.EXE -DeploymentType Uninstall -DeployMode Silent';
                        'ContentLocation' = $ContentLocation;
                        'InstallationBehaviorType' = $InstallationBehaviorType;
                        'InstallationProgramVisibility' = 'Hidden';
                        'MaximumAllowedRunTimeMinutes' = '120';
                        'EstimatedInstallationTimeMinutes' = $EstimatedTime;
                        'DetectDeploymentTypeByCustomScript' = $true;
                        'ScriptType' = 'PowerShell';
                        'ScriptContent' = 'blah';
                        'LogonRequirementType' = 'WhetherOrNotUserLoggedOn';
                    }

            }
      

        "Interactive" {

                $AddCMDeploymentTypeParams = @{
                    'ApplicationName' = $ApplicationFullName;
                    'DeploymentTypeName' = $Name + " " + 'Install';
                    'ScriptInstaller' = $true;
                    'ManualSpecifyDeploymentType' = $true;
                    'InstallationProgram' = 'Deploy-Application.EXE';
                    'UninstallProgram' = 'Deploy-Application.EXE -DeploymentType Uninstall -DeployMode Silent';
                    'ContentLocation' = $ContentLocation;
                    'InstallationBehaviorType' = $InstallationBehaviorType;
                    'InstallationProgramVisibility' = 'Normal';
                    'MaximumAllowedRunTimeMinutes' = '120';
                    'EstimatedInstallationTimeMinutes' = $EstimatedTime;
                    'DetectDeploymentTypeByCustomScript' = $true;
                    'ScriptType' = 'PowerShell';
                    'ScriptContent' = 'blah';
                }
            }
        }
}	

Process {

        $NewCMApplication = @{
        'Name' = $ApplicationFullName
        'Owner' = $Owner
        'SupportContact' = $SupportContact
        'Publisher' = $Publisher
        'SoftwareVersion' = $SoftwareVersion
        }

        Write-Verbose -Message "Creating $ApplicationFullName application container..."
        New-CMApplication @NewCMApplication -ErrorAction Stop | Out-Null	
        
        Write-Verbose -Message "Creating deployment type..."
        Add-CMDeploymentType @AddCMDeploymentTypeParams -ErrorAction Stop | Out-Null

        If ($DistributionPointGroupName -ne $null){
            
            Write-Verbose -Message "Starting Distribution to $DistributionPointGroupName"
            Start-CMContentDistribution -ApplicationName $ApplicationFullName -DistributionPointGroupName $DistributionPointGroupName
        
        } 

        Try {
            
            Set-CMApplication -Name $ApplicationFullName -UserCategories $CatalogCategory
        }
        
        Catch [System.Management.Automation.ItemNotFoundException]{

            "No Applications found with $ApplicationID"
        }
        
        Catch {

            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
    
    
    }
    	
End {
	

    }


}
