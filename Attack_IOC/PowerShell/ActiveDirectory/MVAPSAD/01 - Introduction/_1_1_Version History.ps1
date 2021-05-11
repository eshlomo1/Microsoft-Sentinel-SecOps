break


& ".\PowerShell Cmd Line Conversion Guide AD.pdf"
















#------------------------------------------------------------------------------
# CMD
#------------------------------------------------------------------------------

DSGET

DSQUERY




#------------------------------------------------------------------------------
# REPADMIN
#------------------------------------------------------------------------------

# A quick replication health report
repadmin /showrepl * /csv | ConvertFrom-CSV | Out-GridView

# Replication health for a site
repadmin /showrepl * /csv | ConvertFrom-CSV |
 Where-Object {$_."Source DSA Site" -eq "Ohio"} | Out-GridView

# Replication health grouped by naming context (database partition)
repadmin /showrepl * /csv | ConvertFrom-CSV |
 Sort-Object "Naming Context" | Format-Table -GroupBy "Naming Context"

#------------------------------------------------------------------------------
# WHOAMI
#------------------------------------------------------------------------------

# A convenient list of my group memberships.
whoami /groups /fo csv | ConvertFrom-Csv | Out-GridView

# Grab the logged in user SID quickly.
$UserSID = whoami /user /fo csv | ConvertFrom-Csv | Select-Object -ExpandProperty SID
$UserSID

#------------------------------------------------------------------------------
# CSVDE
#------------------------------------------------------------------------------

# We can't leave out the classic CSVDE, a constant since Windows 2000.
# You could even recycle some existing scripts that use CSVDE.
csvde -p Subtree -l "cn,description" -d "dc=cohovineyard,dc=com" -r "(objectClass=group)" -f csvde.txt
Import-Csv .\csvde.txt | Out-GridView

#------------------------------------------------------------------------------
# DSQUERY, DSGET, DSMOD, etc.
#------------------------------------------------------------------------------






#------------------------------------------------------------------------------
# WMI
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Domain
# Includes trusted domains
#------------------------------------------------------------------------------
gwmi Win32_NTDomain | select * | ogv

#------------------------------------------------------------------------------
# Account parent class
# Three child classes: Group, SystemAccount, UserAccount
#------------------------------------------------------------------------------
gwmi Win32_Account | select * | ogv
#------------------------------------------------------------------------------
gwmi Win32_Group | select * | ogv
gwmi Win32_SystemAccount | select * | ogv
# Notice that the user list includes trusted domains
gwmi Win32_UserAccount | select * -First 50 | ogv
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Groups
#------------------------------------------------------------------------------
gwmi -list *group*

gwmi win32_group | ft sidtype, domain, name
gwmi win32_group | gm

gwmi win32_groupuser | gm
# Notice this one pulls from all trusted domains
gwmi win32_groupindomain | gm
gwmi win32_groupindomain | select GroupComponent, PartComponent | ogv


#------------------------------------------------------------------------------
# User accounts
#------------------------------------------------------------------------------

gwmi -list *user*

# Get User Data
gwmi Win32_UserAccount | Select-Object * -First 10 | ogv

gwmi Win32_UserAccount | Select-Object -First 10 |
 ft Name, Domain, Disabled, Lockout, PasswordChangeable, PasswordRequired, SID -AutoSize

# List all of the user profiles on a box, including their SIDs.
gwmi Win32_UserProfile | ogv
# Notice that UserProfile has a method to ChangeOwner
# That could be handy during migrations.
gwmi Win32_UserProfile | gm


#------------------------------------------------------------------------------
# Computers
#------------------------------------------------------------------------------
# Tons of specs at a glance
gwmi Win32_ComputerSystem | fl *
# Handy methods: JoinDomainOrWorkgroup, UnjoinDomainOrWorkgroup, Rename
gwmi Win32_ComputerSystem | gm -MemberType Method


#------------------------------------------------------------------------------
# MicrosoftActiveDirectory NameSpace
# 
# PROs:
#  Use the computername parameter to hit any DC since Windows 2003.
#  Cool stuff: trusts, replication, domain SIDs, repl GUIDs, etc.
# CONs:
#  No real forest scope for queries.
#  View all data from perspective of a single DC.
#  Requires iterations to crawl and discover the whole forest.
#  No way to enumerate DCs for the forest.
#------------------------------------------------------------------------------
# DUMP ALL AD WMI DATA AVAILABLE
# Properties with data
gwmi -namespace root\MicrosoftActiveDirectory -list |
 foreach-object {gwmi -namespace root\MicrosoftActiveDirectory -class $_.Name | fl *}
# Methods
gwmi -namespace root\MicrosoftActiveDirectory -list |
 foreach-object {$_.Name; gwmi -namespace root\MicrosoftActiveDirectory -class $_.Name |
  get-member -MemberType Method -ea SilentlyContinue}

# These are the only two classes with a method:
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController | gm -MemberType Method
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_ReplNeighbor | gm -MemberType Method

# For another DC
gwmi -computername dcc -namespace root\MicrosoftActiveDirectory -list |
 foreach-object {gwmi -namespace root\MicrosoftActiveDirectory -class $_.Name | fl *}

# List all classes in the AD namespace
gwmi -namespace root\MicrosoftActiveDirectory -list
# Filter out the "__Class" names
gwmi -namespace root\MicrosoftActiveDirectory -list [a-z]*

# Domain Controller
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController -computername dca | fl *
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController -computername dca | gm

# ExecuteKCC method
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController -computername dca | gm -MemberType Method | fl *
# Name       : ExecuteKCC
# MemberType : Method
# Definition : System.Management.ManagementBaseObject ExecuteKCC(System.UInt32 TaskID, System.UInt32 dwFlags)
#  These method calls don't exactly work for me yet:
#  (gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController -computername dca).ExecuteKCC(0,1)
#  Invoke-WmiMethod -namespace root\MicrosoftActiveDirectory -class MSAD_DomainController -name ExecuteKCC -ArgumentList 0,1 -computername dca

# Local Domain Info
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo | fl *
# Just the good stuff
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo |
 ft DCname, DNSname, FlatName, SID, TreeName -AutoSize
# Just the SID
(gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo).sid

# Trust status report
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_DomainTrustStatus |
 ft TrustedDomain, TrustDirection, TrustType, TrustIsOk

# REPADMIN replication status
# Beef this up to resolve the DSA GUIDs to server names so that it is meaningfull
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_ReplCursor | ft NamingContextDN, TimeOfLastSuccessfulSync

# All of the partitions I host with GCs noted
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_NamingContext | ft DistinguishedName, IsFullReplica -AutoSize

# REPADMIN replication status
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_ReplNeighbor | ft __SERVER, NamingContextDN, SourceDsaCN, LastSyncResult, TimeOfLastSyncSuccess -AutoSize
# Replication full detail
gwmi -namespace root\MicrosoftActiveDirectory -class MSAD_ReplNeighbor | ogv

# Trusted Domain SIDs
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_DomainTrustStatus | ft TrustedDomain, SID

# My Domain SID
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo | ft DNSname, SID

# Local domain info for a remote domain by name
gwmi -namespace root\MicrosoftActiveDirectory -class Microsoft_LocalDomainInfo -computername fun.wingtiptoys.local | fl *


#------------------------------------------------------------------------------
# The Directory Service Provider
#  Root\Directory\LDAP
# See book by Alain Lissoir for details, "Leveraging WMI Scripting".
#  Alain Lissoir
#  http://www.lissware.net/
#  Understanding Windows Management Instrumentation (WMI) Scripting (580 pages)
#  Leveraging Windows Management Instrumentation (WMI) Scripting (918 pages)
#------------------------------------------------------------------------------

gwmi -namespace Root\Directory\LDAP -list | ogv





#------------------------------------------------------------------------------
# ADSI
#------------------------------------------------------------------------------

# A "type accelerator" is a short name for a longer .NET type.
# Compare the TypeName output at the top of each of these commands.
[System.DirectoryServices.DirectoryEntry] | gm -s
[ADSI] | gm -s

# Here is a simple example of referencing a user account.
$a = [ADSI]"LDAP://cn=administrator,cn=users,dc=cohovineyard,dc=com"
$a
$a | gm
$a | fl *

# We can reference the root of the domain by passing an empty string.
$domain = [ADSI]""
$domain








#------------------------------------------------------------------------------
# .NET
#------------------------------------------------------------------------------


# FORESTS
$forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$forest | fl *
$forest | gm -m method | fw

$forest.Domains        | ogv
$forest.Sites          | ogv
$forest.GlobalCatalogs | ogv

# Forest FSMOs
$forest.SchemaRoleOwner
$forest.SchemaRoleOwner.Roles
$forest.NamingRoleOwner

# Tons of cool methods
$forest | gm -MemberType method | fl Name, Definition

# Trusts
$forest.GetAllTrustRelationships()

# GCs
$forest.FindAllGlobalCatalogs() | ogv

# RaiseForestFunctionality, etc.


# DOMAINS
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$domain | fl *
$domain | gm -m method | fw

$domain.DomainControllers | ogv

# FSMOs
$domain.PdcRoleOwner
$domain.RidRoleOwner
$domain.InfrastructureRoleOwner

# List all domain controllers for all domains in the forest (assuming not all are GCs)
$DCs = @()
ForEach ($domain in $forest.domains) {
    $DCs += $domain.DomainControllers
}
$DCs | ogv


# Using context in .NET
# You cannot reference a named domain by string; you must pass an object.

# This fails:
$remoteforest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest("cohovineyard.com")

# This works:
$context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Forest","cohovineyard.com")
$remoteforest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($context)
$remoteforest

# Here is a full example from my module on SID history
$DomainSIDList = @{}
$trusts = $forest.GetAllTrustRelationships()
ForEach ($trust in $trusts) {
  $trust.TrustedDomainInformation |
    ForEach-Object {
        $DomainSIDList.Add($_.DnsName, $_.DomainSid)
        # Get all forest trusts from remote trusted forests
        $context = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Forest",$_.DnsName)
        $remoteforest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($context)
        $remotetrusts = $remoteforest.GetAllTrustRelationships()
        ForEach ($remotetrust in $remotetrusts) {
          $remotetrust.TrustedDomainInformation | 
            ForEach-Object {
                $DomainSIDList.Add($_.DnsName, $_.DomainSid)
            }
        }
    }
}
$DomainSIDList | ft -AutoSize
