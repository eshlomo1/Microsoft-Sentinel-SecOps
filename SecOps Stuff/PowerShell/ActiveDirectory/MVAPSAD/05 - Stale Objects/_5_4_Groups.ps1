break

Set-Location 'C:\Users\administrator.COHOVINEYARD\Documents\MVA\05 - Stale Objects'

# Group stats report

Get-ADGroup -Filter * -Properties Name, DistinguishedName, `
        GroupCategory, GroupScope, whenCreated, whenChanged, member, `
        memberOf, sIDHistory, SamAccountName, Description |
    Select-Object Name, DistinguishedName, GroupCategory, GroupScope, `
        whenCreated, whenChanged, member, memberOf, SID, SamAccountName, `
        Description, `
        @{name='MemberCount';expression={$_.member.count}}, `
        @{name='MemberOfCount';expression={$_.memberOf.count}}, `
        @{name='SIDHistory';expression={$_.sIDHistory -join ','}}, `
        @{name='DaysSinceChange';expression=`
            {[math]::Round((New-TimeSpan $_.whenChanged).TotalDays,0)}} |
    Sort-Object Name | ogv


# Revisit group metadata
# Notice the parameter -ShowAllLinkedValues
Get-ADReplicationAttributeMetadata 'CN=Legal,OU=Groups,DC=CohoVineyard,DC=com' -Server localhost -ShowAllLinkedValues | Out-GridView


<#-----------------------------------------------------------------------------
Search for groups with duplicate group membership, Group report
Ashley McGlone, Microsoft Premier Field Engineer
-------------------------------------------------------------------------------

This script compares group memberships for the entire domain to find
duplication. This involves an "n * n-1" number of comparisons. The following
steps have been taken to make the comparisons more efficient:

- Minimum number of members in a group before it is considered for matching
  This automatically filters out empty groups and those with only a few members.
  This is an arbitrary number. Default is 5. Must be at least 1.

- Minimum percentage of overlap between group membership counts to compare
  ie. It only makes sense to compare groups whose total membership are close
  in number. You wouldn't compare a group with 5 members to a group with 65
  members when seeking a high number of group member duplicates. By default
  the lowest group count must be within 25% of the highest group count.

- Does not compare the group to itself.

- The pair of groups has not already been compared.

Groups of all types are compared against each other in order to give a complete
picture of group duplication (Domain Local, Global, Universal, Security,
Distribution). If desired, mismatched group category and scope can be filtered
out in Excel when viewing the CSV file output.

Using the data from this report you can then go investigate groups for
consolidation based on high match percentages.

-------------------------------------------------------------------------------

The group list report gives you handy fields for analyzing your groups for
cleanup:  whenCreated, whenChanged, MemberCount, MemberOfCount, SID,
SIDHistory, DaysSinceChange, etc.  Use these columns to filter or pivot in
Excel for rich reports.  For example:
- Groups with zero members
- Groups unchanged in 1 year
- Groups with SID history to cleanup
- Etc.
-----------------------------------------------------------------------------#>

Import-Module ActiveDirectory

#region########################################################################
# Tuning parameters for group member matching
# Due to the number of possible group comparisons the execution time could be
# significant. These two threshold values will speed up the process by weeding
# out unlikely matches.

# Minimum number of members in a group before it is considered for matching
# This automatically filters out empty groups and those with only a few members.
# This is an arbitrary number.  Must be at least 1.
$MinMember = 5

# Minimum percentage of overlap between group membership counts to compare
# ie. It only makes sense to compare groups whose total membership are close in
# number. You wouldn't compare a group with 5 members to a group with 65 members
# when seeking a high number of group member duplicates.  This is an arbitrary
# number.
$CountPercentThreshold = 75
#endregion#####################################################################

# Initialize arrays and hashtables
$report = @()
$done = @{}

#region########################################################################
# List of all groups and the count of their member/memberOf
# You could edit this query to limit the scope and filter by:
# - group name pattern
#      -Filter {name -like "*foo*"}
# - group scope
#      -Filter {GroupScope -eq 'Global'}
# - group category
#      -Filter {GroupCategory -eq 'Security'}
# - OU path
#      -SearchBase 'OU=Groups,OU=NA,DC=contoso,DC=com' -SearchScope SubTree
# - target GC port 3268 and query for only Universal groups to compare
#      -Server DC1.contoso.com:3268 -Filter {GroupScope -eq "Universal"}
# - etc.
Write-Progress -Activity "Getting group list..." -Status "..."
$GroupList = Get-ADGroup -Filter * -Properties Name, DistinguishedName, `
        GroupCategory, GroupScope, whenCreated, whenChanged, member, `
        memberOf, sIDHistory, SamAccountName, Description |
    Select-Object Name, DistinguishedName, GroupCategory, GroupScope, `
        whenCreated, whenChanged, member, memberOf, SID, SamAccountName, `
        Description, `
        @{name='MemberCount';expression={$_.member.count}}, `
        @{name='MemberOfCount';expression={$_.memberOf.count}}, `
        @{name='SIDHistory';expression={$_.sIDHistory -join ','}}, `
        @{name='DaysSinceChange';expression=`
            {[math]::Round((New-TimeSpan $_.whenChanged).TotalDays,0)}} |
    Sort-Object Name

$GroupList |
    Select-Object Name, SamAccountName, Description, DistinguishedName, `
        GroupCategory, GroupScope, whenCreated, whenChanged, DaysSinceChange, `
        MemberCount, MemberOfCount, SID, SIDHistory |
    Export-CSV .\GroupList.csv -NoTypeInformation
#endregion#####################################################################

#region########################################################################
# Outer loop of all groups
# Minimize expensive group comparison operations:
# - There are more than x members in the group
ForEach ($GroupA in ($GroupList | `
    Where-Object {$_.MemberCount -ge $MinMember})) {

    $CountA = $GroupA.MemberCount

    # Inner loop of all groups
    # Minimize expensive group comparison operations:
    # - Group SIDs are not equal
    # - There are more than x members in the group
    ForEach ($GroupB in ($GroupList | Where-Object `
        {$_.MemberCount -ge $MinMember -and $_.SID -ne $GroupA.SID})) {

        $CountB = $GroupB.MemberCount
        
        Write-Progress `
            -Activity "Comparing members of $($GroupA.Name)" `
            -Status "To members of $($GroupB.Name)"
        
        # Calculate the percentage of overlap between group membership counts
        If ($CountA -le $CountB) {
            $CountPercent = $CountA / $CountB * 100
        } Else {
            $CountPercent = $CountB / $CountA * 100
        }

        # Minimize expensive group comparison operations:
        # - The pair of groups has not already been compared
        # - The difference in total group count is not more than x%
        If ( (!$done.ContainsKey("$($GroupA.SID)~$($GroupB.SID)")) -and `
             $CountPercent -ge $CountPercentThreshold ) {
        
            # This is the heart of the script. Compare group memberships.
            $co = Compare-Object -IncludeEqual `
                -ReferenceObject $GroupA.Member `
                -DifferenceObject $GroupB.Member
            $CountEqual = ($co | Where-Object {$_.SideIndicator -eq '=='} | `
                Measure-Object).Count

            # Add an entry for GroupA/GroupB
            $report += New-Object -TypeName PSCustomObject -Property @{
                NameA = $GroupA.Name
                NameB = $GroupB.Name
                CountA = $CountA
                CountB = $CountB
                CountEqual = $CountEqual
                MatchPercentA = [math]::Round($CountEqual / $CountA * 100,2)
                MatchPercentB = [math]::Round($CountEqual / $CountB * 100,2)
                ScopeA = $GroupA.GroupScope
                ScopeB = $GroupB.GroupScope
                CategoryA = $GroupA.GroupCategory
                CategoryB = $GroupB.GroupCategory
                DNA = $GroupA.DistinguishedName
                DNB = $GroupB.DistinguishedName
            }

            # Add an entry for GroupB/GroupA
            # We don't need to process each pair twice,
            # but we will report on each one as A/B and B/A for ease of use.
            $report += New-Object -TypeName PSCustomObject -Property @{
                NameA = $GroupB.Name
                NameB = $GroupA.Name
                CountA = $CountB
                CountB = $CountA
                CountEqual = $CountEqual
                MatchPercentA = [math]::Round($CountEqual / $CountB * 100,2)
                MatchPercentB = [math]::Round($CountEqual / $CountA * 100,2)
                ScopeA = $GroupB.GroupScope
                ScopeB = $GroupA.GroupScope
                CategoryA = $GroupB.GroupCategory
                CategoryB = $GroupA.GroupCategory
                DNA = $GroupB.DistinguishedName
                DNB = $GroupA.DistinguishedName
            }

            # Use a hashtable for quick lookup to see if the
            # pair has already been processed.  In this case
            # we add the pair both ways to register
            # completion.
            $done.Add("$($GroupA.SID)~$($GroupB.SID)",1)
            $done.Add("$($GroupB.SID)~$($GroupA.SID)",1)

        }
    }
} 

$report | 
    Sort-Object CountEqual -Descending | 
    Select-Object NameA, NameB, CountA, CountB, CountEqual, MatchPercentA, `
        MatchPercentB, ScopeA, ScopeB, CategoryA, CategoryB, DNA, DNB | 
    Export-CSV .\GroupMembershipComparison.csv -NoTypeInformation
#endregion#####################################################################

Get-ChildItem .\*.csv

Import-Csv .\GroupMembershipComparison.csv | ogv

