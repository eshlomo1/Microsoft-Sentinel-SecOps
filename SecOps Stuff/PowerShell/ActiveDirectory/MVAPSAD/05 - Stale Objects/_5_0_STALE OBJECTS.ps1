<#

Objective is to give you the tools to create your own stale object
solution.  Most of the pieces are here.  Go forth and script!

ENABLE THE RECYCLE BIN FIRST
Find your stale accounts (users, computers, groups, etc.)
Filter them against your exceptions list.
Disable them after x days.  Update the object description.
Delete them after x more days.
If computer, then delete DNS records also (A, AAAA, PTR).
If anyone complains, use Restore-ADObject.

#>