Function Set–GPOStatus {
<# comment based help is here #>

[cmdletbinding(SupportsShouldProcess)]

Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter the name of a GPO",
ValueFromPipeline,ValueFromPipelinebyPropertyName)]
[Alias("name")]
[ValidateNotNullorEmpty()]
[Parameter(ParameterSetName="EnableAll")]
[Parameter(ParameterSetName="DisableAll")]
[Parameter(ParameterSetName="DisableUser")]
[Parameter(ParameterSetName="DisableComputer")]
[object]$DisplayName,
[Parameter(ParameterSetName="EnableAll")]
[Parameter(ParameterSetName="DisableAll")]
[Parameter(ParameterSetName="DisableUser")]
[Parameter(ParameterSetName="DisableComputer")]
[string]$Domain,
[Parameter(ParameterSetName="EnableAll")]
[Parameter(ParameterSetName="DisableAll")]
[Parameter(ParameterSetName="DisableUser")]
[Parameter(ParameterSetName="DisableComputer")]
[string]$Server,
[Parameter(ParameterSetName="EnableAll")]
[switch]$EnableAll,
[Parameter(ParameterSetName="DisableAll")]
[switch]$DisableAll,
[Parameter(ParameterSetName="DisableUser")]
[switch]$DisableUser,
[Parameter(ParameterSetName="DisableComputer")]
[switch]$DisableComputer,
[Parameter(ParameterSetName="EnableAll")]
[Parameter(ParameterSetName="DisableAll")]
[Parameter(ParameterSetName="DisableUser")]
[Parameter(ParameterSetName="DisableComputer")]
[switch]$Passthru
)

Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
       
    #define a hashtable we can for splatting
    $paramhash=@{ErrorAction="Stop"}
    if ($domain) { $paramhash.Add("Domain",$Domain) }
    if ($server) { $paramhash.Add("Server",$Server) }

} #begin

Process {
    #define appropriate GPO setting value depending on parameter
    Switch ($PSCmdlet.ParameterSetName) {
    "EnableAll" { $status = "AllSettingsEnabled" }
    "DisableAll" { $status = "AllSettingsDisabled" }
    "DisableUser" { $status = "UserSettingsEnabled" }
    "DisableComputer" { $status = "ComputerSettingsEnabled" }
    default {
            Write-Warning "You didn’t specify a GPO setting. No changes will be made."
            Return
            }
    }
    
    #if GPO is a string, get it with Get-GPO
    if ($Displayname -is [string]) {
        $paramhash.Add("name",$DisplayName)
        
        Write-Verbose "Retrieving Group Policy Object"
        Try {
            write-verbose "Using Parameter hash $($paramhash | out-string)"
            $gpo=Get–GPO @paramhash
        }
        Catch {
            Write-Warning "Failed to find a GPO called $displayname"
            Return
        }
    }
    else {
        $paramhash.Add("GUID",$DisplayName.id)
        $gpo = $DisplayName
    }

    #set the GPOStatus property on the GPO object to the correct value. The change is immediate.
    Write-Verbose "Setting GPO $($gpo.displayname) status to $status"

    if ($PSCmdlet.ShouldProcess("$($gpo.Displayname) : $status ")) {
        $gpo.gpostatus=$status
        if ($passthru) {
            #refresh the GPO Object
            write-verbose "Using Parameter hash $($paramhash | out-string)"
            get–gpo @paramhash 
        }
    } #should process

} #process

End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end

} #end Set-GPOStatus