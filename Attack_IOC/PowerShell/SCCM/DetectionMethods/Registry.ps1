if ((Get-ItemProperty 'HKLM:\SOFTWARE\Classes\TypeLib\{656A82C9-0680-4299-81C7-C41ADD503BA2}\1.0\0\win32' -ErrorAction SilentlyContinue) -match 'KPItemTagA.dll'){
Write-Host 'Installed'}
