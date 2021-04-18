Get-ADUser -Filter 'memberOf -RecursiveMatch "CN=Domain Admins,CN=groups,DC=dc,DC=domain,DC=com"'
   
    trap {return "error"}
    If (
        Get-ADUser `
            -Filter "memberOf -RecursiveMatch '$((Get-ADGroup "Domain Admins").DistinguishedName)'" `
            -SearchBase $((Get-ADUser $user).DistinguishedName)
        ) {$true}
        Else {$false}
