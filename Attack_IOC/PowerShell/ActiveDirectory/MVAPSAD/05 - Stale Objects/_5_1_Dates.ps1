break


# Discover the date properties of a user

Get-ADUser administrator | 
    Get-ADObject -Properties * | 
    Get-Member -MemberType Property |
    Sort-Object Definition | 
    Select-Object Definition

Get-ADUser administrator | 
    Get-ADObject -Properties * | 
    Get-Member -MemberType Property | 
    Where-Object {$_.definition -like 'System.DateTime*' -or `
                  $_.definition -like 'System.Int64*'} 


# View all the dates on an account

$DateProperties = Get-ADUser administrator | 
    Get-ADObject -Properties * | 
    Get-Member -MemberType Property | 
    Where-Object {$_.definition -like 'System.DateTime*' -or `
                  $_.definition -like 'System.Int64*'} 

$DatePropertyNames = $DateProperties | Select-Object -ExpandProperty Name | Where-Object {$_ -notin 'ObjectClass', 'ObjectGUID', 'uSNChanged', 'uSNCreated'}

Get-ADUser administrator | Get-ADObject -Properties $DatePropertyNames | Select-Object * -ExcludeProperty ObjectClass, ObjectGUID
Get-ADUser administrator -Properties $DatePropertyNames | Select-Object * -ExcludeProperty ObjectClass, ObjectGUID, SID, DistinguishedName, Enabled, Givenname, Surname, SamAccountName

# What about those long, ugly INT64 numbers?

# From DateTime to UTC
Get-Date
[datetime]::Now
[datetime]::UtcNow
[datetime] | gm -Static
(Get-Date).ToFileTimeUTC()
(Get-Date).ToFileTime()

# pwdLastSet

# From FileTime (or UTC) to DateTime
[datetime]::fromFileTime((Get-ADUser Administrator -Properties pwdLastSet | Select-Object -ExpandProperty pwdLastSet))
[datetime]::fromFileTimeUTC((Get-ADUser Administrator -Properties pwdLastSet | Select-Object -ExpandProperty pwdLastSet))

# Password last set within the last 30 days?
$pwdLastSet = Get-ADUser Administrator -Properties pwdLastSet | Select-Object -ExpandProperty pwdLastSet
# Option A
$pwdLastSet -gt (Get-Date).AddDays(-30).ToFileTimeUTC()
# Option B
[datetime]::fromFileTime($pwdLastSet) -gt (Get-Date)



<##############################################################################

This script reports password expiration dates for all accounts in the forest.

Find password change policy with 

pwdLastSet is NOT a GC attribute. Must query one DC in each domain directly.

PasswordExpires calculated by adding 45 or 90 days to PwdLastSet

##############################################################################>

$DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

ForEach ($DC in $DCs) {

        $DC
        Get-ADUser -Filter "pwdLastSet -gt $((Get-Date).AddDays(-90).ToFileTimeUTC())" -Server $DC.DC -Properties displayName, description, city, state, country, countryCode, pwdLastSet, PasswordNeverExpires, whenCreated, whenChanged, LastLogonTimestamp |
         Select-Object *, `
            @{name='Domain';expression={$DC.Domain}}, `
            @{name='lastLogonTimestampConverted';expression={[datetime]::fromFileTime($_.lastLogonTimestamp)}}, `
            @{name='pwdLastSetConverted';expression={[datetime]::fromFileTime($_.pwdlastset)}}, `
            @{name='passwordExpires';expression={If ($DC.Domain -eq 'contoso.com') {$PwdPolicy = 45} Else {$PwdPolicy = 90}; [datetime]::fromFileTime($_.pwdlastset).AddDays($PwdPolicy)}}, `
            @{name='passwordExpiresDayOfYear';expression={[datetime]::fromFileTime($_.pwdlastset).AddDays(90).dayOfYear}} |
         Select-Object *, `
            @{name='passwordExpiresYear';expression={$_.passwordExpires.Year}}, `
            @{name='passwordExpiresWeekOfYear';expression={[int]($_.passwordExpires.dayOfYear/7)}} `
            -ExcludeProperty PropertyNames, PropertyCount, ObjectClass, ObjectGUID, SID |
         Export-Csv ".\PwdLastSet_$($DC.Domain).csv" -NoTypeInformation -Encoding Unicode
}


# Render meaningful date
# NOTE: AccountExpires is the manual date set for an account to expire
<#
http://msdn.microsoft.com/en-us/library/windows/desktop/ms675098(v=vs.85).aspx
The date when the account expires. This value represents the number of 100-nanosecond intervals since January 1, 1601 (UTC).
A value of 0 or 0x7FFFFFFFFFFFFFFF (9223372036854775807) indicates that the account never expires.
#>
Get-ADUser -Filter * -Properties pwdLastSet, lastLogonTimeStamp, accountExpires |
 Select-Object DistinguishedName, `
    pwdLastSet, @{name='pwdLastSetConverted';expression={[datetime]::fromFileTime($_.pwdlastset)}}, `
    lastLogonTimeStamp, @{name='lastLogonTimeStampConverted';expression={[datetime]::fromFileTime($_.lastLogonTimeStamp)}}, `
    accountExpires, @{name='accountExpiresConverted';expression={[datetime]::fromFileTime($_.accountExpires)}} |
 Out-GridView


# whenChanged is not a replicated attribute.
# Consider it informational only, unless you write a routine to collect it from all DCs
# and keep the newest value.
Get-ADUser administrator -Properties whenChanged, Modified, ModifyTimestamp -Server CVDC1
Get-ADUser administrator -Properties whenChanged, Modified, ModifyTimestamp -Server CVDCR2



