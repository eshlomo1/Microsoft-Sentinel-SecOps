<#
    Sam The Admin - Find any computer accounts that have a invalid SamAccountName 
    To run remotely use the combination of Get-WinEvent
    November Update - CVE-2021-42287 and CVE-2021-42278  
    More information: https://exploit.ph/cve-2021-42287-cve-2021-42278-weaponisation.html
#>
$EventIds = @{
    35    = "PAC without attributes"
    36    = "Ticket without a PAC"
    37    = "Ticket without Requestor"
    38    = "Requestor Mismatch"
    4662  = "Aמ operation was performed on an object"
    4741  = "A computer account was created"
    4781  = "Aמ account was changed"
    4738  = "A user account was changed"
    16990 = "Object class and UserAccountControl validation failure"
    16991 = "SAM Account Name validation failure"
}
#
$DomainController = Get-ADDomain | Select-Object -ExpandProperty ReplicaDirectoryServers
foreach ($ComputerName in $DomainController) {
    $Events = Invoke-Command -ComputerName $ComputerName -ScriptBlock { param([string[]]$EventIds) $EventIds | Out-Null ; Get-WinEvent -EA 0 -FilterHashtable @{LogName = 'System'; id = $EventIds } | Where-Object { $_.ProviderName -in @('Microsoft-Windows-Kerberos-Key-Distribution-Center', 'Microsoft-Windows-Directory-Services-SAM') } } -ArgumentList (, $EventIds.Keys)

    foreach ($Event in $Events) {
        [PSCustomObject]@{
            TimeCreated = $Event.TimeCreated
            Id          = $Event.Id
            EventGroup  = $EventIds[$Event.Id]
            Reason      = $Event.Message
        }
    }
}
