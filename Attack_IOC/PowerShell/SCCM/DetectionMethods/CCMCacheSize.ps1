#Initialize our CCM COM Objects
 $CCM = New-Object -com UIResource.UIResourceMGR
 
 #USe GetCacheInfo method to return Cache properties
 $CCMCache = $CCM.GetCacheInfo()

 if ($CCMCache.TotalSize -ge '10240') { Write-Host '10GB cache' }
