function ConvertTo-DSCPullArchive
{
<#
.Synopsis
   Converts PowerShell Modules to compressed .zip files.
.DESCRIPTION
   Converts PowerShell Modules to compressed .zip files
   used by Desired State Configuraiton pull servers.
.PARAMETER Source
    Specifies the source location of a PowerShell module.
.PARAMETER Destination
    Specifies the destination that the compressed module will be placed. 
.EXAMPLE
    ConvertTo-DSCPullArchive -Source "C:\LabResources\xTimeZone" -destination 'c:\temp'
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Source,
        $Destination
    )

    Begin
    {
        $Version = (Get-ChildItem -Path $source -Depth 1).Name
        $ResoureName = (Get-ChildItem -Path $source -Depth 1).Parent.Name
        $ModuleName = $ResoureName+'_'+$Version
        $destinationZip = ($destination+'\'+$ModuleName)+'.zip'
    }
    Process
    {
        New-Item -Path ($destination+'\'+$ResoureName) -ItemType Directory
        $Copy = Get-Item -Path ($destination+'\'+$ResoureName) 
        Get-ChildItem ($source+'\'+$Version) | Copy-Item -Destination ($destination+'\'+$ResoureName)
        If(Test-path $destinationZip) {Remove-item $destinationZip -Force}
        
        Set-Content -path $destinationZip -value ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) -ErrorAction Stop
        
        $zipfile = Get-Item $destinationZip
        $zipfile.IsReadOnly = $false
        
        Write-Verbose "Creating Shell.Application"
        $shellApp = New-Object -com shell.application
        
        Write-Verbose "Using namespace $($zipfile.fullname)" 
        $zipPackage = $shellApp.NameSpace($zipfile.fullname)
        
        
        $target = Get-Item -Path $Copy
        
        $zipPackage.CopyHere($target.FullName) 
        
        Start-Sleep -Milliseconds 200
        
        New-DscCheckSum -ConfigurationPath $destinationZip -OutPath $destination -Verbose -Force
    }
    End
    {
        Remove-Item -Path ($destination+'\'+$ResoureName) -Confirm:$false -Recurse
    }
}