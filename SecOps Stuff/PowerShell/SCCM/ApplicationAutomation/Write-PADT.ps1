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
    $PADTtemplate = ($PADTtemplate).Replace("<#Author#>","'$env:USERNAME'")
    
    Write-Verbose -Message "Outputtin script to $ScriptOutLocation"
    $PADTtemplate | Out-String | Out-File "$ScriptOutLocation\Deploy-Application.ps1" -Force

    }#end
}
