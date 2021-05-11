function <name> {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER
.EXAMPLE
#>
    [CmdletBinding()]
    param(
        [string]
    )
    BEGIN {}
    PROCESS {}
    END {}
}


Function set-function {
[cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="High")]

Param (
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a computername")]
[ValidateNotNullorEmpty()]
[string]$Param

)
Begin {

} #Begin

Process {
    
} #Process

End {

} #end

}
