New-Item (Join-Path (Split-Path $profile.CurrentUserCurrentHost) "Snippets") -ItemType Directory

New-IseSnippet -Title 'Try Catch Get-ADUser' -Description 'Try Catch block with AD object not found catch block' -Text 'Try {
    Get-ADUser -Identity $User
}
Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Write-Warning "$User could not be found"
}' -CaretOffset 4

Try {
    Get-ADUser -Identity $User
}
Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Write-Warning "$User could not be found"
}