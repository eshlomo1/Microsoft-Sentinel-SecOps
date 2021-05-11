#requires -version 3.0

Function New-ZipArchive {

<#
.Synopsis
Create a zip archive from a folder.
.Description
This command will create a zip file from the specified path. The path will be a top level folder in the archive.
.Parameter Path
The top level folder to be archived. This parameter has aliases of PSPath and Source.
.Parameter OutputPath
The filename for the zip file to be created. If it already exists, the command will not run, unless you use -Force. This parameter has aliases of Zip and Target.
.Parameter Force
Delete the existing zip file and create a new one.
.Example
PS C:\> New-ZipArchive -path c:\work -outputpath e:\workback.zip 

Create a new zip file called WorkBack.zip. The top level folder in the archive will be Work.
.Example
PS C:\> $dscres = Get-DSCResource | Select -expandproperty Module -unique | where {$_.path -notmatch "windows\\system32"}
PS C:\> $dscres | foreach {
 $out = "{0}_{1}.zip" -f $_.Name,$_.Version
 $zip = Join-Path -path "E:\DSC\ZipResource" -ChildPath $out
 New-ZipArchive -path $_.ModuleBase -OutputPath $zip -Passthru -force
 }

 The first command gets a unique list of modules for all DSC resources filtering out anything under System32. The second command creates a zip file for each module using the naming format modulename_version.zip.

.Notes
Version      : 1.0
Last Updated : February 2, 2015

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/


  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

#>

[cmdletbinding(SupportsShouldProcess)]
param(
[Parameter(Position=0,Mandatory,
HelpMessage="Enter the folder path to be archived.")]
[Alias("PSPath","Source")]
[String]$Path,
[Parameter(Position=1,Mandatory,
HelpMessage="Enter the path and filename for the zip file")]
[Alias("zip","Target")]
[ValidateNotNullorEmpty()]
[String]$OutputPath,
[Switch]$Force,
[switch]$Passthru
)

Write-Verbose "Starting $($MyInvocation.Mycommand)"  
Write-Verbose "Using bound parameters:"
Write-verbose  ($MyInvocation.BoundParameters| Out-String).Trim()

if ($Force -AND (Test-Path -path $OutputPath)) {
    Write-Verbose "Testing for existing file and deleting it"
    Remove-Item -Path $OutputPath
}
     
if(-NOT (Test-Path $OutputPath)) {
    Write-Verbose "Creating $OutputPath" 
    Try {
        #create an empty zip file
        Set-Content -path $OutputPath -value ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) -ErrorAction Stop
        
        #get the zip file object
        $zipfile = $OutputPath | Get-Item -ErrorAction Stop

        #make sure it is not set to ReadOnly
        write-verbose "Setting isReadOnly to False"
        $zipfile.IsReadOnly = $false  
    }
    Catch {
        Write-Warning "Failed to create $outputpath"
        write-Warning $_.exception.message
        #bail out
        Return
    }
} #if not test zip file path
else {
    Write-Warning "The file $OutputPath already exists. Please delete or use -Force and try again."
    
    #bail out
    Return
}

if ($PSCmdlet.ShouldProcess($Path)) {
    Write-Verbose "Creating Shell.Application"
    $shellApp = New-Object -com shell.application

    Write-Verbose "Using namespace $($zipfile.fullname)" 
    $zipPackage = $shellApp.NameSpace($zipfile.fullname)

    write-verbose ($zipfile | Out-String)

    $target = Get-Item -Path $Path

    $zipPackage.CopyHere($target.FullName) 

    If ($passthru) {
        #Pause enough to give the zip file a chance to update
        Start-Sleep -Milliseconds 200
        Get-Item -Path $Outputpath
    }
} #should process

Write-Verbose "Ending $($MyInvocation.Mycommand)"

} #close New-ZipFile function

<#
Get-Module xTimeZone -list | foreach {
 $out = "{0}_{1}.zip" -f $_.Name,$_.Version
 $zip = Join-Path -path "d:\temp" -ChildPath $out
 New-ZipArchive -path $_.ModuleBase -OutputPath $zip -Passthru -force -verbose
}

$m = Get-Module ISEScriptingGeek -ListAvailable
New-ZipArchive $m.ModuleBase "e:\$($m.name).zip"
#>


