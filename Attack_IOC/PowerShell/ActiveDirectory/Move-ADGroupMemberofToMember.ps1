function Move-ADGroupMemberofToMember {
<#
.SYNOPSIS
Moves all Member Of objects to the Members section of an Active Directory group.
.DESCRIPTION
Queries an Active Directory group for all Member Of groups then add them to the members section
and removes them from the member of section of the active directory group.
.PARAMETER TargetGroup
Specify the group to run the cmdlet against.
.EXAMPLE
Move-ADGroupMemberOfToMember -TargetGroup GroupTest01 -Verbose
#>
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)]
    [string]$TargetGroup
)
BEGIN {
    Write-Verbose -message "Gathering all Member of objects"
    $Groups = (Get-ADGroup -Identity $TargetGroup -Properties *).Memberof
}
PROCESS {
   foreach ($Group in $Groups) {
        Try {
            Write-Verbose -message "Adding $Group as member"
            Add-ADGroupMember -Identity $TargetGroup -Members $Group
            Write-Verbose -message "Removing $Group from Member of"
            Remove-ADGroupMember -Identity $Group -Members $TargetGroup -Confirm:$false
        }
        Catch [Microsoft.ActiveDirectory.Management.ADException] {
            Write-Warning -message "$Group was already a member of $TargetGroup"
            Write-Verbose -message "Removing $Group from Member of"
            Remove-ADGroupMember -Identity $Group -Members $TargetGroup -Confirm:$false
        }
    }
}
END {
    Write-Verbose -message "Migration of Member of to Member complete"
}
}
