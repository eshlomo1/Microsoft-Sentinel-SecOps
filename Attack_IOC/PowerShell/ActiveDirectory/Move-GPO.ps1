function Move-GPO {
<#
.Synopsis
   Moves a Group Policy from one Domain to another.
.DESCRIPTION
   Backsup an existing GPO to be copied and migrated to a target server in a different domain.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    $Name,
    
    [string]
    $Path,

    [Parameter(Mandatory=$true)]
    $Target,
    
    [string]
    $ComputerName = $env:COMPUTERNAME,

    [System.Management.Automation.PSCredential]
    [System.Management.Automation.CredentialAttribute()]    
    $Credential
)

    Begin
    {
        Write-Verbose -Message "Verifying Group Poilcy $GPOName exists"

        $GPOName = $Name
        #(Get-GPO -Name $Name).DisplayName

        if ($PSBoundParameters.ContainsKey('Path')){
        } else {
            $Path = "$env:SystemDrive\GPOs" + '\' + $GPOName
        }
        Write-Verbose -Message "Group Policy backup path is $Path"

        $SessionParms = @{
            'ComputerName' = $ComputerName
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
                $SessionParms.Add('Credential',$Credential)
        }
        
        if(-not (Test-Path $Path)){
            Write-Verbose "Creating $Path"
            New-Item -ItemType Directory -Path $Path | Out-Null
        }
    }
    Process
    {
        Write-Verbose -Message "Backing up $GPOName to $Path on $env:COMPUTERNAME"
        #Backup-GPO -Name $GPOName -Path $Path

        if ($env:COMPUTERNAME -ne $ComputerName){
            $session = New-PSSession @SessionParms
            
            Write-Verbose -Message "Copying Group Policy backup to $ComputerName"
            Copy-Item $Path -Recurse -Destination $Path -TOsession $session -Force
            
            Write-Verbose -Message "Importing $GPOName on $ComputerName"
            Invoke-Command -Session $session `
            -ScriptBlock {param($GPOName,$Path)Import-Module GroupPolicy;Import-GPO -BackupGpoName $GPOName -CreateIfNeeded -Path $Path -TargetName $GPOName} -ArgumentList $GPOName,$Path

            Write-Verbose -Message "Linking $GPOName to $Target"
            Invoke-Command -Session $session `
            -ScriptBlock {param($GPOName,$Target)Import-Module GroupPolicy;New-GPLink -Name $GPOName -Target $Target} -ArgumentList $GPOName,$Target

        } else {
            Write-Verbose -Message "Importing $GPOName on $ComputerName"
            Import-GPO -BackupGpoName $GPOName -CreateIfNeeded -Path $Path -TargetName $GPOName

            Write-Verbose -Message "Linking $GPOName to $Target"            
            New-GPLink -Name $GPOName -Target $Target
        }
    }
    End
    {
        Write-Verbose -Message "Publishing $GPOName complete..."
    }
}