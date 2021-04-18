<#
.SYNOPSIS

Gather MSI information

.DESCRIPTION

Invokes methods to query all msi files at a specific location.

.PARAMETER Path

Provide the location of the .MSI file.

.PARAMETER Property

Select one of the three properties to return from the .MSI file.
ProductCode,ProductVersion,ProductName

.Example

Get-MSIinfo -Path C:\MSI -Property ProductCode

.Link

http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/


#>

function Get-MSIinfo {

    param(
    [parameter(Mandatory=$true)]
    [IO.FileInfo]$Path,
    [parameter(Mandatory=$true)]
    [ValidateSet("ProductCode","ProductVersion","ProductName")]
    [string]$Property
    )
        try {
            $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
            $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase","InvokeMethod",$Null,$WindowsInstaller,@($Path.FullName,0))
            $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
            $View = $MSIDatabase.GetType().InvokeMember("OpenView","InvokeMethod",$null,$MSIDatabase,($Query))
            $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
            $Record = $View.GetType().InvokeMember("Fetch","InvokeMethod",$null,$View,$null)
            $Value = $Record.GetType().InvokeMember("StringData","GetProperty",$null,$Record,1)
            return $Value
        } 
        catch {
            Write-Output $_.Exception.Message
        }

}

Function Write-PADT {
<#
.SYNOPSIS

This script will write a PowerShell Application Deployment Toolkit (PSADT) script.

.DESCRIPTION

Using information provided by the parameters of the script, this PowerShell script will
generate a script that can be used by PowerShell Application Deployment Toolkit to install
software and make changes to the system which the software is being installed.

.PARAMETER 

.EXAMPLE

Write-PADT -InstallFile "setup.exe","installer.msi" -InstallString "/S","/qn" -InstallFilex64 "install.exe","installer.msi" -InstallStringx64 "/S","/QN" -Vendor Cylance -Name Protect -Version 1.0 -CloseApps iexplorer -SourceFolderPath 'C:\SourceContent' -ModifiedPADT "C:\Users\joshua.duffney\OneDrive\PowerShell\PADT 3.5 Template\Deploy-Application.ps1"

.Notes

This script was created to automate the creation of the deploy-application.ps1 scripts used
for powershell application deployment toolkit. A template deploy-application.ps1 is downloaded
and modified to include all the comment blocks for the replace section, this enables the script
to fill in the different sections of the script with the desired input. 

.LINK

CodePlex
http://psappdeploytoolkit.codeplex.com/

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
    
    [string[]]$CloseApps,
        
    [string]$SourceFolderPath,
    
    [string]$ModifiedPADT,

    [string]$ScriptOutLocation
             
    )

Begin {

        #Import-Module .\Get-MSIinfo.psm1
        $Date = Get-Date -Format d
        $InstallFile = $InstallFile.Split(",")
        $InstallString = $InstallString.Split(",")
        $InstallFilex64 = $InstallFilex64.Split(",")
        $InstallStringx64 = $InstallStringx64.Split(".")
	}#End Begin
	
Process {

    For($i=0;$i -lt $InstallFilex64.length;$i++){

        If ($InstallFilex64 -ne "") {
            $InstallCode += 'if ($is64bit) {'

                    For($i=0;$i -lt $InstallFilex64.length;$i++){
                
                    if ($InstallFilex64[$i] -match ".msi") {            
                        $InstallCode += "`n`t" + 'Execute-MSI -Action Install -Path "$dirFiles\' + $installfilex64[$i] + '" -Parameters "' + $InstallStringx64[$i] + '"'
                    }
                    if ($InstallFilex64[$i] -match ".exe") {
                        $InstallCode += "`n`t" + 'Execute-Process -FilePath "$dirFiles\' + $installfilex64[$i] + '" -Arguments "' + $InstallStringx64[$i] + '"'
                    }
                }
            }#end for
        } #end if
               
               if ($InstallFilex64 -ne ""){
                    $InstallCode += "`n`t" + '} else {' + "`t"
               }
        
        For($i=0;$i -lt $InstallFile.length;$i++){
            if ($InstallFile){
                If ($InstallFile[$i] -match ".msi") {
                    $InstallCode += "`n`t" + 'Execute-MSI -Action Install -Path "$dirFiles\' + $installfile[$i] + '" -Parameters "' + $InstallString[$i] + '"'
                    } else {
                    $InstallCode += "`n`t" + 'Execute-Process -FilePath "$dirFiles\' + $installfile[$i] + '" -Arguments "' + $InstallString[$i] + '"'
                    }
                }#end if
            }#end for
        
        if($InstallFilex64 -ne ""){
                $InstallCode += "`n`t} `n"
            }
        #Write-host $InstallCode -ForegroundColor Green
        Write-Verbose $InstallCode

        $Paths = (Get-ChildItem -path $SourceFolderPath -Recurse *.msi).FullName
            Foreach ($MSI in $Paths) { 
            if ($MSI) {
            $UninstallStrings += (Get-MSIinfo -Path "$MSI" -Property ProductCode)
            }
        }#end foreach


        foreach ($String in $UninstallStrings) {
            if($String) {
            $UninstallCode += "`n`t" + 'Execute-MSI -Action Uninstall -Path' + " " + '"' + $String + '"'
            }
        }#end foreach

        Write-Verbose $UninstallCode

   } #end Process
	
End {

    $PADTtemplate = Get-Content -path $ModifiedPADT
    
    if ($CloseApps -ne ""){
        $PADTtemplate = ($PADTtemplate).Replace("<#CloseApps#>","-CloseApps '$CloseApps'")
        }
    
    $PADTtemplate = ($PADTtemplate).Replace("<#InstallCode#>","$InstallCode")
    $PADTtemplate = ($PADTtemplate).Replace("<#UninstallCode#>","$UninstallCode")
    $PADTtemplate = ($PADTtemplate).Replace("<#Vendor#>","'$Vendor'")
    $PADTtemplate = ($PADTtemplate).Replace("<#Name#>","'$Name'")
    $PADTtemplate = ($PADTtemplate).Replace("<#Version#>","'$Version'")
    $PADTtemplate = ($PADTtemplate).Replace("<#Date#>","'$Date'")
    $PADTtemplate = ($PADTtemplate).Replace("<#Author#>","'Automation'")
    
    Write-Verbose -Message "Outputtin script to $ScriptOutLocation"
    $PADTtemplate | Out-String | Out-File "$ScriptOutLocation\Deploy-Application.ps1" -Force

    }#end
}

Function New-ContentSource {
<#
.SYNOPSIS
    This function creates the folder stucture for the SCCM applicaiton and copies required files.
.DESCRIPTION
    Creates a contentsource folder at the specified path with the naming convention 
    vendor_softwarename_version. It then copies all files necessary for PowerShell
    Application Deployment Toolkit to operate to that location. Finally it copies all
    files from a specified location to the new server share.
.PARAMETER PADTFiles
    Path to all PowerShell Application Deployment toolkit support files
.PARAMETER ApplicationSourceContent
    Name of the folder to be created at the new ContentSource location
    on the file server.
.PARAMETER SourceFolderPath
    Location of the source files to be copied to the new ContentSource
    location on the file server.
.EXAMPLE
    New-ContentSource -PADTFiles \\Server\Share\PADTfiles -ApplicationSourceContent Vendor_SoftwareName_Version -SourceFolderPath D:\SourceContent
.NOTES
    The purpose of this function is to get variable data from another source,
    then dynamically create SourceContent folders on an ConfigMgr file server
    to be used for ConfigMgr applications.
.LINK

#>

[CmdletBinding()]
	
	param (
    [string]$PADTFiles,
	
    [string]$ApplicationSourceContent,

    [string]$SourceFolderPath
    )

Try
    {
        Write-Verbose -Message "Creating $ApplicationSourceContent directory"
        mkdir $ApplicationSourceContent -ErrorAction Stop

        Write-Verbose -Message "Copying $PADTFiles to $ApplicationSourceContent"
        Copy-Item "$($PADTFiles)\*" -Destination $($ApplicationSourceContent) -Recurse -Force

        Write-Verbose -Message "Copying $SourceFolderPath to $ApplicationSourceContent"
        Copy-Item "$($SourceFolderPath)\*" -Destination "$($ApplicationSourceContent)\Files" -Recurse -Force
    }
Catch [System.IO.IOException]
    {
        Write-Warning -Message "$ApplicationSourceContent already exists..." -ErrorAction SilentlyContinue
    }
Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
    }

}

Function Enter-CMSession {
<#
.SYNOPSIS

Imports the System Center Configuration Manager Module & Connects to Configuration Manager PS-Drive.

.DESCRIPTION

Imports the System Center Configuration Manager module and then changes location to the sitecode PS drive specified.

.PARAMETER SiteCode

Specifies the SiteCode of the SCCM server to connect to.

.EXAMPLE

Enter-SCCMSession -SiteCode KLP

#>
[CmdletBinding()]

param (
  [Parameter(Mandatory=$True,HelpMessage="Enter the SiteCode of the SCCM Server")]
  [String]$SiteCode
  )

    Try
    {
    Write-Verbose "Connecting to $computername"
        if (!(Test-Path "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1")) {
            Write-Error 'Configuration Manager module not found. Is the admin console installed?'
            } elseif (!(Get-Module 'ConfigurationManager')) {
                Import-Module "$(Split-Path $env:SMS_ADMIN_UI_PATH -Parent)\ConfigurationManager.psd1"
            }
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
        Write-Verbose "Finished running command"
        "This Script attempted to import the SCCM module"
    }
}
Function Set-CMVendorfolder {
<#
.SYNOPSIS
    Creates a folder in ConfigMgr to orginize Applications.
.DESCRIPTION
    Creates a folder within the ConfigMgr applications PS
    Drive with the name of the vendor specified and moves
    the ConfigMgr application to that folder. If the vendor
    folder already exists then it will move the application
    inside the folder and not create a new folder.
.PARAMETER ApplicationFullName
    Specify the full name of the application as listed in the
    Configuration Manager Console.
.PARAMETER Vendor
    Provide the name of the vendor of the specified application.
.EXAMPLE
    Set-CMVendorfolder -ApplicationFullName 'NotepadTM Notepad++ 6.8.8' -Vendor NotepadTM
.NOTES
    This function was created to help orginize ConfigMgr environments,
    providing stucture for all appliactions within the console.
#>

[CmdletBinding()]
	
	param (
	
    [string]$ApplicationFullName,
    [string]$Vendor
	
    )

Begin {

        Write-Verbose -Message "Gathering inforamtion on $ApplicationFullName"
        $CMApplication = Get-CMApplication -Name $ApplicationFullName
        Set-Location .\Application
    }

Process {  
     
        Try
        {
            Write-Verbose -Message "Creating Vendor folder $Vendor"
            New-Item -Name $Vendor -ErrorAction SilentlyContinue
            
            Write-Verbose -Message "Moving $ApplicationFullName to $Vendor folder"
            Move-CMObject -FolderPath $Vendor -InputObject $CMApplication -ErrorAction Stop | Out-Null
            cd ..
        }
        Catch [System.InvalidOperationException]
        {
            Write-Verbose -Message "$Vendor folder already existed...moving $ApplicationFullName"
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

Function New-ConfigMgrApplication {
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER CabFilePath

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
