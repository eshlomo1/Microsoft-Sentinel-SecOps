# ---------------------------------------------------
# Version: 1.0
# Author: Joshua Duffney
# Date: 07/18/2014
# Description: Create CM Catalog Categories from a .txt file
# Comments: Populate the names of the desired catalog categories line by line in catalogcategories.txt
# ---------------------------------------------------

Function NewCMCatalogCategories {

Param(
    [string]$SiteServerName,
    [string]$SiteCode,
    [string]$Path
)
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
# Create Catalog Catagories
    ForEach ($Category in (Get-Content $Path))
    {
        $CategoryTest =  Get-CMCategory -Name "$Category"
    
        if ($CategoryTest -eq $null){
        New-CMCategory -CategoryType CatalogCategories -Name $Category | Out-Null
        Write-Host -ForegroundColor Green "$Category Created"
        } 
        else 
        {
        Write-Host -ForegroundColor red "$Category already exists"
        }
    }

}

NewCMCatalogCategories -SiteServerName ServerName -SiteCode SiteCode -Path "C:\scripts\catalogcategories.txt"
