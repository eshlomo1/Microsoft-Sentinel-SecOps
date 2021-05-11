Invoke-Command -VMName Win10 -ScriptBlock {Set-Location $env:windir\System32\sysprep;cmd /c "Sysprep.exe /oobe /generalize /shutdown"} -Credential administrator
