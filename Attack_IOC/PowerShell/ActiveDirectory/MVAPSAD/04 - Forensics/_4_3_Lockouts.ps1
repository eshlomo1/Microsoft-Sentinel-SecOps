# Troubleshooting Account Lockout
# http://technet.microsoft.com/en-us/library/cc773155(v=ws.10).aspx

break

# View the domain security audit policy
# Windows Settings \ Security Settings \ Advanced Audit Configuration
Get-GPO -Name 'Default Domain Policy'
Get-GPResultantSetOfPolicy -Computer localhost -User administrator -ReportType Html -Path .\rsop.html
Start-Process .\rsop.html

# Display local audit policy
auditpol --% /get /Category:"Logon/Logoff","Account Logon"

# Description of security events in Windows 7 and in Windows Server 2008 R2 
# http://support.microsoft.com/kb/977519/en-us

# Logon audit failure events
# Event 4625 is bad password in client log
# Event 4771 is bad password in DC log
# Event 4740 is lockout in DC log

# View the current password lockout policy
Get-ADDefaultDomainPasswordPolicy -Current LoggedOnUser

# Any locked out accounts?
Search-ADAccount -LockedOut

# Lock out the ANLAN account
#  (Use HyperV VM view)

# Any locked out accounts?
Search-ADAccount -LockedOut

# Set up the lockout report
$report = @()
$user = "anlan"

# Pick the DCs to crawl
$DCs = Get-ADDomainController -Filter * |
    Select-Object HostName, IPv4Address, Site, OperatingSystem, OperationMasterRoles |
    Out-Gridview -Title "Select the DCs to query" -PassThru |
    Select-Object -ExpandProperty HostName

# Find the lockout stats for that user on all selected DCs
ForEach ($DC in $DCs) {
    $report += Get-ADUser $user -Server $DC -ErrorAction Continue `
        -Properties cn, LockedOut, pwdLastSet, badPwdCount, badPasswordTime, lastLogon, lastLogoff, lastLogonTimeStamp, whenCreated, whenChanged | `
        Select-Object *, @{name='DC';expression={$DC}} 
}

$DCs = $report |
    Select-Object `
        DC, `
        cn, `
        LockedOut, `
        pwdLastSet, `
        @{name='pwdLastSetConverted';expression={[datetime]::fromFileTime($_.pwdlastset)}}, `
        badPwdCount,
        badPasswordTime, `
        @{name='badPasswordTimeConverted';expression={[datetime]::fromFileTime($_.badPasswordTime)}}, `
        lastLogon, `
        @{name='lastLogonConverted';expression={[datetime]::fromFileTime($_.lastLogon)}}, `
        lastLogoff, `
        @{name='lastLogoffConverted';expression={[datetime]::fromFileTime($_.lastLogoff)}}, `
        lastLogonTimeStamp, `
        @{name='lastLogonTimestampConverted';expression={[datetime]::fromFileTime($_.lastLogonTimestamp)}}, `
        whenCreated, `
        whenChanged |
    Out-GridView -Title "Select the DC to query event logs for lockouts" -PassThru



# Add parallel here:
#   Workflow
#   PSSession
#   Invoke-Command
#   Runspaces

# Filter generated using Event Viewer GUI Custom View
# Logon/Lockout events in the last 24 hours
[xml]$xmlFilter = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=529 or EventID=644 or EventID=675 or EventID=676 or EventID=681 or EventID=4740 or EventID=4771) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
"@


$Events = @()
ForEach ($DC in $DCs) {

    "Getting events from $($DC.DC)"

    # Must enable the firewall rule for remote EventLog management
    Invoke-Command -ComputerName $DC.DC -ScriptBlock {Get-NetFirewallRule -Name *eventlog* | Where-Object {$_.Enabled -eq 'False'} | Enable-NetFirewallRule -Verbose}

    ### Filter for the userID in the event message properties
    # Filter for last 24 hours
    #Get-WinEvent -ComputerName $DC.DC -LogName Security -FilterXPath "*[System[(EventID=529 or EventID=644 or EventID=675 or EventID=676 or EventID=681 or EventID=4625) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]" #-MaxEvents 50
    $Events += Get-WinEvent -ComputerName $DC.DC -FilterXML $xmlFilter

    # Terribly inefficient, but works
    #Get-EventLog -ComputerName $DC.DC -LogName Security | Where-Object {$_.EventID -in @(529, 644, 675, 676, 681)}
}

ForEach ($Event in $Events) {
    # Convert the event to XML
    $eventXML = [xml]$Event.ToXml()
    # Iterate through each one of the XML message properties
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {
        # Append these as object properties
        Add-Member -InputObject $Event -MemberType NoteProperty -Force `
            -Name  $eventXML.Event.EventData.Data[$i].name `
            -Value $eventXML.Event.EventData.Data[$i].'#text'
    }
}

# View the lockout details
$Events | Where-Object {$_.TargetUserName -eq $user} | Select-Object TargetUserName, IPAddress, MachineName, TimeCreated | Out-GridView

$Events | fl *
$Events | Select-Object * -ExcludeProperty Message | Out-GridView
$Events | Export-Csv .\AcctLockout.csv -NoTypeInformation



<#

You probably don't need ACCTINFO2.DLL
http://blogs.technet.com/b/askds/archive/2011/04/12/you-probably-don-t-need-acctinfo2-dll.aspx


Audit Logon - 4625
http://technet.microsoft.com/en-us/library/dd941635(v=WS.10).aspx

Security ID
Account Name
Account Domain
Workstation Name
Source Network Address


Audit Account Lockout - 4625
http://technet.microsoft.com/en-us/library/dd941583(v=ws.10).aspx

Description of security events in Windows Vista and in Windows Server 2008
http://support.microsoft.com/kb/947226

Security Event Descriptions
http://support.microsoft.com/kb/174074

How to use the EventCombMT utility to search event logs for account lockouts
http://support.microsoft.com/kb/824209
    #Events 529 644 675 676 681

Account Lockout and Management Tools
http://www.microsoft.com/en-us/download/details.aspx?id=18465


   Event ID: 529
       Type: Failure Audit
Description: Logon Failure:
             Reason: Unknown user name or bad password
             User Name: %1              Domain: %2
             Logon Type: %3             Logon Process: %4
             Authentication Package: %5 Workstation Name: %6

   Event ID: 539
       Type: Failure Audit
Description: Logon Failure:
             Reason: Account locked out
             User Name: %1              Domain: %2
             Logon Type: %3             Logon Process: %4
             Authentication Package: %5 Workstation Name: %6

   Event ID: 644
 Event Type: Success Audit
Description: User Account Locked Out
Target Account Name:  %1   Target Account ID: %2
Caller Machine Name:  %3    Caller User Name:  %4
Caller Domain:      %5        Caller Logon ID:  %6

#>

