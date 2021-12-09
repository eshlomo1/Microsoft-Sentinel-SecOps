Connect-AzAccount

Invoke-WebRequest -Uri 'https://account.blob.core.windows.net/container/azcopy.zip' -OutFile .\azcopy.zip
Expand-Archive -Path .\azcopy.zip -DestinationPath .\
Remove-Item -Path .\azcopy.zip

Invoke-WebRequest -Uri 'https://account.blob.core.windows.net/container/dumpit.zip' -OutFile .\dumpit.zip
Expand-Archive -Path .\dumpit.zip -DestinationPath .\
Remove-Item -Path .\Dumpit.zip

.\DumpIt.exe /N /Q

.\azcopy.exe copy "*.json" "https://account.blob.core.windows.net/container" --overwrite=false --from-to=LocalBlob --blob-type=BlockBlob --put-md5;
.\azcopy.exe copy "*.dmp" "https://account.blob.core.windows.net/container" --overwrite=false --from-to=LocalBlob --blob-type=BlockBlob --put-md5;

#Downloads
#https://zeltser.com/memory-acquisition-with-dumpit-for-dfir-2/
#https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
