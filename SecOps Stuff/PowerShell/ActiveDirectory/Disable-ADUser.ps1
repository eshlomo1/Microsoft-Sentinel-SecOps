function Disable-ADUser {
<#
.SYNOPSIS
Disables Users and moves them to the specified OU.
.DESCRIPTION
Take string or object input for Users then disables each one and moves to the specified ou
then outputs errors to a log file.
.PARAMETER Identity
Name of user or Users
.PARAMETER DisabledOU
Specifies the Distinguished Name of the OU the device will be moved to.
.PARAMETER Domain
Specifies the domain in which to query for the user given to the Identity parameter. If left blank it will query the domain of the currently logged on user.
.PARAMETER Description
By default this will append to the existing description of the user object and append any text given to this parameter.
.PARAMETER PSCredential
Allows the use of alternate credentials in for form doman\user.
.EXAMPLE
Disable-ADUser -Identity user1 -DisabledOU 'OU=Users,OU=Disabled Accounts,DC=domain,DC=com' -Description "CR00001' -Domain domain.forest.com -Verbose -whatif
.EXAMPLE
Disable-ADUser -Identity user1 -PSCredential domain\user -Description "CR00001" -verbose
#>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string[]]$Identity,
        [string]$DisabledOU,
        [string]$Domain = (Get-ADDomain).DNSroot,
        [string]$Description = $null,
        [string]$ErrorLog = "$env:SystemDrive\retry.txt",
        $PSCredential
    )
    BEGIN {
        
        Write-Verbose -Message "Starting Disable-ADUser"
        if ($PSCredential){
            $SecurePassword = Read-Host -Prompt "Enter Password" -AsSecureString
            $PSCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $PSCredential,$SecurePassword
        }    
    }
    
    PROCESS {

        foreach($ID in $Identity){
                
 
            Try {

                $GetParms = @{
                    'Identity' = $ID
                    'Server' = $Domain
                }

                if ($Description) {$GetParms.Add('Properties','Description')}
                if ($PSCredential) {$GetParms.Add('Credential',$PSCredential)}

                $UserInfo = Get-ADUser @GetParms
                $Description = $($UserInfo.Description) + " "+ $Description

                $SetParms = @{
                    'Identity' = $ID
                    'Server' = $Domain
                    'Enabled' = $false
                }

                if ($Description -ne ' ') {$SetParms.Add('Description',$Description)}
                if ($PSCredential) {$SetParms.Add('Credential',$PSCredential)}

                Write-Verbose -Message "Disabling $ID"
                
                Set-ADUser @SetParms

                if ($DisabledOU){

                    $MoveParms = @{
                        'Identity' = $($UserInfo.DistinguishedName)
                        'TargetPath' = $DisabledOU
                        'Server' = $Domain
                    }
                    if ($PSCredential) {$MoveParms.Add('Credential',$PSCredential)}

                    Write-Verbose -Message "Moving $ID to $DisabledOU"

                    Move-ADObject @MoveParms
                }
                
            }
            Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
                Write-Warning -Message "$Identity was not found"
                Write-Output  -InputObject $Identity | Out-File $ErrorLog
            }
            Catch {
                Write-Warning -Message $_.Exception.Message
            }
        }
    }
    END {
        Write-Verbose -Message "Finished"
    }
}