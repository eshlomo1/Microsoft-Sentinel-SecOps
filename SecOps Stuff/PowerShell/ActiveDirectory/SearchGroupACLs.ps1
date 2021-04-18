#Slack Test
$Domain = "Domain"
$GroupName = "Enterprise Admins"
$Groups = Get-ADGroup -Filter * -ResultSetSize 5| select DistinguishedName,SamAccountName

foreach ($Group in $Groups) {

    Try {
        $ACL = ((Get-Acl $Group.DistinguishedName -ErrorAction SilentlyContinue).access.IdentityReference).value
        if ($ACL -notcontains $Domain +'\'+$GroupName) {
            Write-Host $Group.SamAccountName -ForegroundColor Green
        }
    } Catch [System.Management.Automation.DriveNotFoundException] {
    }
}
