Function Migrate-CMApplication {
<#
.SYNOPSIS
Migrates a ConfigMgr Application from one instance to another.
.DESCRIPTION
Looks for an applicaiton based off the localized display name in ConfigMgr
Then exports the applicaiton to a specifed location, once complete it connects
to the second ConfigMgr instance and imports the application.
.PARAMETER SourceSiteCode
Sitecode of the ConfigMgr instance that has exports the application.
.PARAMETER DestinationSiteCode
Sitecode of the ConfigMgr instance that imports the application.
.PARAMETER ExportLocation
Location of the .zip file producted by exporting and used for
importing.
.PARAMETER LocalizedDisplayName
Name of the application being exported and imported
.EXAMPLE
Migrate-CMApplication -SourceSiteCode PS0 -DestinationSiteCode PS1 -ExportLocation "\\Server01\Exports" -LocalizedDisplayName "Java6"
.Notes
.LINK
#>
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$True,HelpMessage="Enter the source sitecode.")]
      [Alias('Source')]
      [String]$SourceSiteCode,
  
      [Parameter(Mandatory=$True,HelpMessage="Enter the destination sitecode.")]
      [Alias('Destination')]
      [String]$DestinationSiteCode,
  
      [Parameter(Mandatory=$True,HelpMessage="Enter the export location.")]
      [String]$ExportLocation,
  
      [Parameter(Mandatory=$True,HelpMessage="Enter the name of the ConfigMgr Application.")]
      [Alias('Application Name')]
      [String[]]$LocalizedDisplayName
      )
    BEGIN{
    }    
    Process{
        Try
        {
            $Export = $True
            Write-Verbose "Connecting to $SourceSiteCode..."
            Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -ErrorAction Stop
            Set-Location "$($SourceSiteCode):"
        }
        Catch [System.IO.FileNotFoundException]
        {
            $Export = $false
            Write-Error "SCCM Admin Console not installed"
        }
        Catch
        {
            $Export = $false
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
        If ($Export) {
            Write-Verbose "Exporting $LocalizedDisplayName..."
            $LocalizedDisplayName = (Get-CMApplication | Where-Object {$_.LocalizedDisplayName -like "*$LocalizedDisplayName*"}).LocalizedDisplayName
            Export-CMApplication -Path "$ExportLocation\$LocalizedDisplayName.zip" -Name "$LocalizedDisplayName" -OmitContent -IgnoreRelated
            }
        Try
        {
            $Import = $True
            Write-Verbose "Connecting to $DestinationSiteCode..."
            Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1" -ErrorAction Stop
            Set-Location "$($DestinationSiteCode):"
        }
        Catch [System.IO.FileNotFoundException]
        {
            $Import = $false
            Write-Error "SCCM Admin Console not installed"
        }
        Catch
        {
            $Import = $false
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
        If ($Import){
            Write-Verbose "Importing $LocalizedgetDisplayName..."
            Import-CMApplication -FilePath "$ExportLocation\$LocalizedDisplayName.zip"
        }
        Try
        {
            Write-Verbose "Moving app to Vendor folder"
            $CMApplication = Get-CMApplication -Name $LocalizedDisplayName
            Set-Location .\Application
            $Vendor = (Get-CMApplication -Name $LocalizedDisplayName).Manufacturer        
            New-Item -Name $Vendor | Out-Null
            Move-CMObject -FolderPath $Vendor -InputObject $CMApplication -ErrorAction Stop | Out-Null
            cd ..
        }
        Catch [System.InvalidOperationException]
        {
            Move-CMObject -FolderPath $Vendor -InputObject $CMApplication -ErrorAction Stop | Out-Null
            cd ..
        }
        Catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }    
    }
}
