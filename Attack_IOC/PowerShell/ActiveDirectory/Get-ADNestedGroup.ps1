function Get-ADNestedGroup ($Group) {
    $Members = (Get-ADGroupMember -Identity $Group).samAccountName

    foreach ($Member in $Members){
        try {
            Get-ADGroup -Identity $Member
            
            if (Get-ADGroup -Identity $Member) {
               Get-ADNestedGroup -Group $Member
            }


        } 
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning -Message "$Member is not a group"
        }
    }
}

Get-ADNestedGroup -group 'DevOpsTeam'