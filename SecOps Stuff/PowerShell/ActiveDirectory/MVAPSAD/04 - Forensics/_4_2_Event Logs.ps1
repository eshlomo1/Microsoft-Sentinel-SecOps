break

# HOW TO WORK WITH EVENT LOGS AND FILTERING
# THIS SETS US UP FOR LOCKOUTS NEXT


# Filter generated using Event Viewer GUI Custom View
# Logon/Lockout events in the last 24 hours
[xml]$xmlFilter = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=529 or EventID=644 or EventID=675 or EventID=676 or EventID=681 or EventID=4740 or EventID=4771) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
"@

$DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName
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
