break

# Partition GUID
Get-ADDomain | ft Name, ObjectGUID -AutoSize

# Invocation ID
Get-ADDomainController -Filter * | ft Name, Domain, HostName, InvocationId -AutoSize

# Naming contexts
Get-ADRootDSE
(Get-ADRootDSE).namingContexts
Get-ADForest
(Get-ADForest).PartitionsContainer
Get-ADObject -SearchBase (Get-ADForest).PartitionsContainer -Filter * -Properties * | ft Name, nCName, objectGUID



# /Queue
# Returns the contents of the replication queue for a specified server.
repadmin /queue
Get-ADReplicationQueueOperation -Server localhost

# /ShowUTDVec
repadmin /ShowUTDVec localhost "dc=cohovineyard,dc=com"
# Default list
Get-ADReplicationUpToDatenessVectorTable -Target localhost -Partition "dc=cohovineyard,dc=com"
# Out-GridView
Get-ADReplicationUpToDatenessVectorTable -Target localhost | Select-Object * | Out-GridView


# Create a replication issue.  Shutdown a DC.
Stop-Computer -ComputerName CVDC1-CL0001 -Force

# Illustrating various ways to call Sync-ADObject
# First sync to a good DC
Sync-ADObject -Object "CN=guest,CN=Users,DC=CohoVineyard,DC=com" -Source CVDC1 -Destination CVDCR2
# Use the Sync-ADObject to force a replication error
Sync-ADObject -Object (Get-ADUser Guest) -Source CVDC1 -Destination CVDC1-CL0001
Get-ADUser -Identity Guest | Sync-ADObject -Destination CVDC1-CL0001

# Restart CVDC1-CL0001

# /ReplSum
repadmin /ReplSum
# Replication failures
Get-ADReplicationFailure -Scope Forest | ogv
Get-ADReplicationFailure -Scope Domain | ogv
Get-ADReplicationFailure -Scope Server -Target CVDCR2 | ogv
Get-ADReplicationFailure -Scope Server -Target CVDC1-CL0001 | ogv
Get-ADReplicationFailure -Scope Site -Target Ohio | ogv

# Replication health overview
Get-ADReplicationPartnerMetadata -PartnerType Both -Scope Domain
# *** Replication health report
Get-ADReplicationPartnerMetadata -PartnerType Both -Scope Domain | Select-Object Server, Partner, PartnerType, Partition, ConsecutiveReplicationFailures, LastReplicationAttempt, LastReplicationResult, LastReplicationSuccess | ogv


# UpToDatenessVectorTable
Get-ADReplicationUpToDatenessVectorTable -Scope Domain | ogv
Get-ADReplicationUpToDatenessVectorTable -Scope Server -Target CVDCR2 | ogv
# Last Replication Success
# One Server
Get-ADReplicationUpToDatenessVectorTable -Scope Server -Target CVDCR2 | Where Partner | ft Server, Partner, LastReplicationSuccess -Wrap
# Forest
Get-ADReplicationUpToDatenessVectorTable -Scope Forest | Where Partner | ft Server, Partner, LastReplicationSuccess -Wrap


<#
Active Directory Replication Status Tool
http://www.microsoft.com/en-us/download/details.aspx?id=30005

Troubleshooting Active Directory Replication Problems
http://technet.microsoft.com/en-us/library/cc738415(v=WS.10).aspx
#>
