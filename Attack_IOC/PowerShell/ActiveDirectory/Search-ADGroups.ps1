$StaleGroupsobj = @()
$DC = 'domain.forest.com'
$Groups = (Get-ADGroup -Filter * -Server $DC).name



Foreach ($Group in $Groups){
    $Group = Get-ADGroup -Filter {Name -eq $Group} -Properties Name, DistinguishedName, `
        GroupCategory, GroupScope, whenCreated, whenChanged, member, `
        memberOf, sIDHistory, SamAccountName, Description -Server $DC |
    Select-Object Name, DistinguishedName, GroupCategory, GroupScope, `
        whenCreated, whenChanged, member, memberOf, SID, SamAccountName, `
        Description, `
        @{name='MemberCount';expression={$_.member.count}}, `
        @{name='MemberOfCount';expression={$_.memberOf.count}}, `
        @{name='SIDHistory';expression={$_.sIDHistory -join ','}}, `
        @{name='DaysSinceChange';expression=`
            {[math]::Round((New-TimeSpan $_.whenChanged).TotalDays,0)}} |
    Sort-Object Name
    
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Name -Value $Group.Name
    $obj | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $Group.DistinguishedName
    $obj | Add-Member -MemberType NoteProperty -Name GroupCategory -Value $Group.GroupCategory
    $obj | Add-Member -MemberType NoteProperty -Name GroupScope -Value $Group.GroupScope
    $obj | Add-Member -MemberType NoteProperty -Name whenCreated -Value $Group.whenCreated
    $obj | Add-Member -MemberType NoteProperty -Name whenChanged -Value $Group.whenChanged
    $obj | Add-Member -MemberType NoteProperty -Name member -Value $Group.member
    $obj | Add-Member -MemberType NoteProperty -Name memberOf -Value $Group.memberOf
    $obj | Add-Member -MemberType NoteProperty -Name SID -Value $Group.SID
    $obj | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $Group.SamAccountName
    $obj | Add-Member -MemberType NoteProperty -Name Description -Value $Group.Description
    $obj | Add-Member -MemberType NoteProperty -Name MemberCount -Value $Group.MemberCount
    $obj | Add-Member -MemberType NoteProperty -Name MemberOfCount -Value $Group.MemberOfCount
    $obj | Add-Member -MemberType NoteProperty -Name SIDHistory -Value $Group.SIDHistory
    $obj | Add-Member -MemberType NoteProperty -Name DaysSinceChange -Value $Group.DaysSinceChange
    $StaleGroupsobj += $obj
}

#Stale Group query
#($StaleGroupsobj | where MemberCount -eq '0' | select Name,MemberCount,MemberofCount,DaysSinceChange | where MemberOfCount -eq '0' | where DaysSinceChange -GE '190'| ft).count
#$StaleGroupsobj = $StaleGroupsobj | Where-Object Name -NotMatch 'Offer Remote Assistance Helpers' | select Name
