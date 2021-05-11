function Get-MDADUser {
<#
.SYNOPSIS
Gets Active Directory user information from all trusted domains.
.DESCRIPTION
Gathers all trusted domains from within a forest and then queries each domain for
the user account specified.
.PARAMETER Identity
Specifies an Active Directory user object by providing one of the following property values.
-- A Distinguished Name
-- A GUID (objectGUID) 
-- A Security Identifier (objectSid) 
-- A SAM Account Name (sAMAccountName)
.PARAMETER Properties
Specifies the properties of the output object to retrieve from the server. Use this parameter to retrieve properties that are not included in the default set.
        
Specify properties for this parameter as a comma-separated list of names. To display all of the attributes that are set on the object, specify * (asterisk).
        
To specify an individual extended property, use the name of the property. For properties that are not default or extended properties, you must specify the LDAP display name of the attribute.
        
To retrieve properties and display them for an object, you can use the Get-* cmdlet associated with the object and pass the output to the Get-Member cmdlet.
.EXAMPLE
Get-MDADUser -Identity duffney -Properties *
#>
[CmdletBinding()]
    param(
    [string]$Identity,
    [string]$Properties
    )

    BEGIN {
        $Server = (Get-ADForest).DomainNamingMaster
        $Domains = (Get-ADObject -Filter {ObjectClass -eq "trusteddomain"} -Server $server).Name
        $Domains += (Get-ADDomain -Server $Server).DNSRoot
    }

    PROCESS {
        foreach ($Domain in $Domains){
            Try {
                if ($Properties -ne ""){
                    Get-ADUser -Identity $Identity -Server $Domain -Properties $Properties
                } else {
                    Get-ADUser -Identity $Identity -Server $Domain
                }
                break
            }
            Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
   
            }
        }
   
    }
}
