break

# Trusts

Get-ADTrust -Filter * | ogv


# Find FSMOs

# netdom /query fsmo
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator

Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster

Get-ADDomainController -Service PrimaryDC -Discover

Get-ADDomainController -Filter * |
     Select-Object Name, Domain, Forest, OperationMasterRoles |
     ft -AutoSize


# FSMO moves

# Transfer one role
Move-ADDirectoryServerOperationMasterRole -Identity CVDC1 `
    -OperationMasterRole PDCEmulator

Get-ADDomainController -Filter * |
     Select-Object Name, Domain, Forest, OperationMasterRoles |
     ft -AutoSize

# Transfer multiple role
Move-ADDirectoryServerOperationMasterRole -Identity CVDC1 `
    -OperationMasterRole RIDMaster,SchemaMaster

Get-ADDomainController -Filter * |
     Select-Object Name, Domain, Forest, OperationMasterRoles |
     ft -AutoSize

# Reference server identity by variable
$server = Get-ADDomainController -Identity cvdc1.cohovineyard.com
Move-ADDirectoryServerOperationMasterRole -Identity $server `
    -OperationMasterRole SchemaMaster,DomainNamingMaster,PDCEmulator,RIDMaster,InfrastructureMaster

Get-ADDomainController -Filter * |
     Select-Object Name, Domain, Forest, OperationMasterRoles |
     ft -AutoSize

# Seize uses -Force
Move-ADDirectoryServerOperationMasterRole -Identity CVDC1 `
    -OperationMasterRole RIDMaster,InfrastructureMaster,DomainNamingMaster -Force

