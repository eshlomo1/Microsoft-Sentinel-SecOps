# ---------------------------------------------------
# Version: 3.0
# Author: Joshua Duffney
# Date: 07/13/2014
# Updated 8/15/2014
# Description: Using PowerShell to create an AD Group & then an SCCM query Collection group to fill it with members of the AD Group.
# Comments: Gathers information from host to create group name\type and specify the managerby field of the AD Group.
# ---------------------------------------------------

Function NewADGrpCMCollection {

    #Collect required data with Paramters
    Param (
        [string]$ServerName,
        [string]$SiteCode,
        [string]$ApplicationName,
        [string]$DeploymentTarget,
        [string]$ADGrpManager,
        [string]$Domain,
        [string]$LimitingCollection
    )
    # Connect to CM
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


    #Switch statment for different deployment groups
    Switch ($DeploymentTarget) {

        "Device"
        {
            #Set CM Collection and ADGrp name variables and ADGrp descritption variables.
            $Name = 'SCCM-SWD-' + $ApplicationName + '-Install'
            $Description = "SCCM AD group for deploying $ApplicationName to devices ONLY"
        
            #Create ADGrp
            New-ADGroup -GroupScope Global -GroupCategory Security -Name $Name -DisplayName $Name -SamAccountName $Name -ManagedBy $ADGrpManager -Description $Description -Path "OU=Groups,OU=Kiewit,DC=KIEWITPLAZA,DC=com"

            #Create CM Collection
            New-CMDeviceCollection -LimitingCollectionName "$LimitingCollection" -Name $Name -RefreshType ConstantUpdate

            #Set CM MembershipQuery
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Name -RuleName "Query-$Name" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = '$Domain\\$Name'"

            #Move CM Collection to Software Folder
            Move-CMObject -InputObject (Get-CMDeviceCollection -Name $Name) -FolderPath .\DeviceCollection\Software
        }
        "User"
            {
            #Set CM Collection and ADGrp name variables and ADGrp descritption variables.
            $Name = "'SCCM-SWU-' + $ApplicationName + '-Install'"
            $Description = "SCCM AD group for deploying $ApplicationName to users ONLY"
        
            #Create ADGrp
            New-ADGroup -GroupScope Global -GroupCategory Security -Name $Name -DisplayName $Name -SamAccountName $Name -ManagedBy $ADGrpManager -Description $Description -Path "OU=Groups,OU=Kiewit,DC=KIEWITPLAZA,DC=com"

            #Create CM Collection
            New-CMUserCollection -LimitingCollectionName "$LimitingCollection" -Name $Name -RefreshType ConstantUpdate

            #Set CM MembershipQuery
            Add-CMUserCollectionQueryMembershipRule -CollectionName $Name -RuleName "Query-$Name" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = '$Domain\\$Name'"

            #Move CM Collection to Software Folder
            Move-CMObject -InputObject (Get-CMUserCollection -Name $Name) -FolderPath .\UserCollection\Software
        }
    }
}

foreach ($App in (Get-Content "C:\scripts\content\adobegrps.txt"))
{
NewADGrpCMCollection -ServerName ServerName -SiteCode SiteCode -ApplicationName "AppName" -DeploymentTarget "Device" -ADGrpManager "Joshua.Duffney" -Domain "Domain" -LimitingCollection "All Desktop Clients"
}
