NetworkAccessTraffic
| where TimeGenerated >= ago(3d)
| where TrafficType == "microsoft365" 
    and DestinationFqdn == "aps.globalsecureaccess.microsoft.com"
| join SigninLogs on UserPrincipalName    
| extend DeviceDisplayName = tostring(DeviceDetail.displayName)
| where AppDisplayName == "ZTNA Network Access Client -- M365"
| where ResultType != "0"
| project TimeGenerated, UserDisplayName, TransactionId, TrafficType, SourceIp, ResultType, DeviceDisplayName 
