 Function Set-CCMCacheSize {
<#
.SYNOPSIS

Changes the size of the Configuration Manager cache folder.

.DESCRIPTION

This function will change the size of the Configuration Manager ccmcache folder.

.PARAMETER CCMCacheSize

Specify the size of the Cache.

.EXAMPLE

Set-CCMCacheSize -CCMCacheSize 10240

.Notes

.LINK

http://blogs.msdn.com/b/helaw/archive/2014/01/07/configuration-manager-cache-management.aspx

#>
[CmdletBinding()]

param (
  [Parameter(Mandatory=$True,HelpMessage="Enter the size of the ccmcache folder")]
  [String]$CCMCacheSize
  )

Begin {

    $CCM = New-Object -com UIResource.UIResourceMGR
 
    #USe GetCacheInfo method to return Cache properties
    $CCMCache = $CCM.GetCacheInfo()
 
    #Get the current cache location
    $CCMCacheDrive = $CCMCache.Location.Split("\")[0]
 
    #Check Free space on drive
    $Drive = Get-WMIObject -query "Select * from Win32_LogicalDisk where DeviceID = '$CCMCacheDrive'"
 
    #Convert freespace to GB for easier check
    $FreeSpace = $Drive.FreeSpace/1GB

    }

Process {

    #Check Sizes and set Cache
    If ($Freespace -ge 5 -and $Freespace -lt 15)
    {
    #Free space moderate
    $CacheSize = 5120
    }
    If ($Freespace -ge 15)
    {
    #Plenty of space
    $CacheSize = $CCMCacheSize
    }
 
    #Set Cache Size
    $CCMCache.TotalSize = $CacheSize

    }
End {
    
     Write-Verbose (Get-WMIObject -namespace root\ccm\softmgmtAgent -class CacheConfig).Size

}

}
