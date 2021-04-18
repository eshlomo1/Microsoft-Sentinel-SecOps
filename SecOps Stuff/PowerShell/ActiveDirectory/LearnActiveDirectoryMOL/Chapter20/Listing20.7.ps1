$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
foreach ($dc in $dom.DomainControllers){
 Get-WmiObject -Class Win32_Volume -ComputerName $dc -Filter "Name='C:\\'" |
 select Name, 
 @{N='Size(GB)'; E={[Math]::Round(($_.Capacity / 1GB),2)}}, 
 @{N='Free(GB)'; E={[Math]::Round(($_.FreeSpace / 1GB), 2)}},
 @{N='PercFree'; E={[Math]::Round((($_.FreeSpace / $_.Capacity) * 100) ,2 )}},
  PSComputerName
}

