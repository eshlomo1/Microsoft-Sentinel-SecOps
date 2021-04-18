$inf = @"
[Version] 
Signature="`$Windows NT`$"

[NewRequest]
Subject = "CN=Pull, OU='IT, O=Globomantics, L=Omaha, S=NE, C=US"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
FriendlyName = PSDSCPullServerCert
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

$infFile = 'C:\temp\certrq.inf'
$requestFile = 'C:\temp\request.req'
$CertFileOut = 'c:\temp\certfile.cer'

mkdir c:\temp
$inf | Set-Content -Path $infFile

& certreq.exe -new "$infFile" "$requestFile"

& certreq.exe -submit -config Pull.globomantics.com\globomantics-PULL-CA -attrib "CertificateTemplate:WebServer" "$requestFile" "$CertFileOut"

& certreq.exe -accept "$CertFileOut"