# VT Dorks to Find Samples Signed with Leaked NVIDIA Certificates
# Source: https://gist.githubusercontent.com/Neo23x0/8ccd7c156f7d08ca08560faca9e63371/raw/208bc0b854d64ca4b13a4034b8801bc1b9ba9411/nvidia_cert_leak_vt_dorks.md

References: 
https://twitter.com/cyb3rops/status/1499514240008437762
https://twitter.com/GossiTheDog/status/1499781976835993600

More background:
https://twitter.com/FuzzySec/status/1499462430275084307

## All files signed with the certificates

All files signed with the affected certificates

```
( signature:"43 bb 43 7d 60 98 66 28 6d d8 39 e1 d0 03 09 f5" OR signature:"14 78 1b c8 62 e8 dc 50 3a 55 93 46 f5 dc c5 18" )
```

## All files submitted after 01.03.2022

All files signed with the affected certificates and submitted after 01.03.2022

```
ls:"2022-03-01T00:00:00+" ( signature:"43 bb 43 7d 60 98 66 28 6d d8 39 e1 d0 03 09 f5" OR signature:"14 78 1b c8 62 e8 dc 50 3a 55 93 46 f5 dc c5 18" )
```

## All files compiled after 01.03.2022

All files signed with the affected certificates and compiled after 01.03.2022

```
creation_date:"2022-03-01T00:00:00+" ( signature:"43 bb 43 7d 60 98 66 28 6d d8 39 e1 d0 03 09 f5" OR signature:"14 78 1b c8 62 e8 dc 50 3a 55 93 46 f5 dc c5 18" )
```
