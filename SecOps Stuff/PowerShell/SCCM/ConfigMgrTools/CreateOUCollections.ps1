# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney
# Date: 08/4/2014
# Description: Creates System Center Configuration Manager collections based on OU information
# Comments: Change "Domain.COM/WORKSTATIONS" in line 18 to the OU path of the OU you are specifying.
# ---------------------------------------------------

Function NewOUCollection {
    Param(
    [string]$SiteServerName,
    [string]$SiteCode,
    [string]$OU,
    [string]$CollectionFolder,
    [string]$CollectionName
    )

    $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemOUName = 'Domain.COM/WORKSTATIONS/$OU'"
    
    ## Import SCCM Module ##
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

    ## Creates CM collection, add query rule and moves to the specified folder
    Try {
    New-CMDeviceCollection -LimitingCollectionName "All Desktop and Server Clients" -Name $CollectionName -RefreshType ConstantUpdate
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -RuleName "Query-$CollectionName" -QueryExpression $QueryExpression
    $Collection = Get-CMDeviceCollection -Name $CollectionName
    Move-CMObject -FolderPath ".\DeviceCollection\$CollectionFolder" -InputObject $Collection -ErrorAction Stop | Out-Null
    }
    Catch {
    }

}

NewOUCollection -SiteServerName "Server" -SiteCode "SiteCode" -OU "OU Name" -CollectionFolder "Software" -CollectionName "Collection'sName"
