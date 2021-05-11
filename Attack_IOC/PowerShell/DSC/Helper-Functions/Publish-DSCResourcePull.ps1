function Publish-DSCResourcePull {
<#
.SYNOPSIS
Copies specified DSC resource module to targert node, creates archive file and checksum for DSC resource.
.DESCRIPTION
Copies specified DSC resource module to the target node's $Env:ProgramFiles\WindowsPowerShell\Modules folder.
Then creates an archive and check some within the DSCServices folder to stage the DSC resource module on the
target node.
.PARAMETER Module
Name of DSC resources modules being published
.PARAMETER ComputerName
Specifies the name of the target node
.PARAMETER Credential
Allows the use of alternate credentials in for form doman\user.
.EXAMPLE
Publish-DSCResourcePull -Module xActiveDirectory -ComputerName ZPull01
.EXAMPLE
Publish-DSCResourcePull -Module xDisk -ComputerName ZPull01 -Credential zephyr\duffney
.Notes
Requires PowerShell v5
#>
[CmdletBinding()]
Param(
    [string[]]
    $Module,

    [string]
    $ComputerName = $env:COMPUTERNAME,

    [System.Management.Automation.PSCredential]
    [System.Management.Automation.CredentialAttribute()]    
    $Credential
)

    $Parms = @{
        'ComputerName' = $ComputerName
    }

    if ($PSBoundParameters.ContainsKey('Credential')){
            $Parms.Add('Credential',$Credential)
    }

    $session = New-PSSession @Parms


    foreach ($ModuleName in $Module){
    
        $ModuleInfo = Get-Module $ModuleName -ListAvailable | Select-Object ModuleBase,Version
        $From = $ModuleInfo.ModuleBase
        $ModuleVersion = $ModuleInfo.Version
        $To =  "$Env:PROGRAMFILES\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion"
    
        Write-Verbose -Message "Copying $ModuleName to $ComputerName..."

        Copy-Item -Path $From -Recurse -Destination $To -ToSession $session

        Write-Verbose -Message "Creating $ModuleName archive..."

        Invoke-Command -Session $session -ScriptBlock {Param($ModuleName,$ModuleVersion)Compress-Archive -Update `
        -Path "$Env:PROGRAMFILES\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion\*" `
        -DestinationPath "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"} `
        -ArgumentList $ModuleName,$ModuleVersion

        Write-Verbose -Message "Creating $ModuleName checksum..."
        Invoke-Command -Session $session -ScriptBlock {New-DscChecksum "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"}
    }

}