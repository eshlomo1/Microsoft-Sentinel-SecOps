break


# BY LAST LOGON

# Quick inactivity report
Search-ADAccount -AccountInactive -UsersOnly | ogv

# Timespan
Search-ADAccount -AccountInactive -UsersOnly -TimeSpan (New-TimeSpan -Days 90) | ogv

# Datetime
Search-ADAccount -AccountInactive -UsersOnly -DateTime '10/1/2014' | ogv

# Disabled
Search-ADAccount -AccountDisabled -UsersOnly


###############################################################################
# Stale User Data
Import-Module ActiveDirectory
Get-ADUser -Filter * -Property sAMAccountName, distinguishedName, PasswordExpired, Enabled, AccountExpirationDate, whenCreated, whenChanged, LastLogonDate, PasswordLastSet, PasswordNeverExpires, PasswordNotRequired, logonCount, userAccountControl -ResultPageSize 200 | Select-Object sAMAccountName, distinguishedName, PasswordExpired, Enabled, @{name='PasswordAgeDays';expression={(New-Timespan -Start $_.PasswordLastSet -End (Get-Date)).Days}}, AccountExpirationDate, @{name='LastLogonDays';expression={(New-Timespan -Start $_.LastLogonDate -End (Get-Date)).Days}}, whenCreated, whenChanged, LastLogonDate, PasswordLastSet, PasswordNeverExpires, PasswordNotRequired, logonCount, userAccountControl | ogv
###############################################################################


# BY PASSWORD LAST SET

# Check the password policies
Get-ADDefaultDomainPasswordPolicy
Get-ADFineGrainedPasswordPolicy -Filter *

# MaxPasswordAge in days
(Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty MaxPasswordAge).TotalDays

### MaxPasswordAge parsed from NET command
net accounts /domain
(net accounts /domain | ? {$_ -like "Maximum password age*"}).Split(':')[1].Trim()

###### None of these take into account Fine Grained Password Policy (FGPP)

### Show me all accounts whose passwords have not been reset within the MaxPasswordAge
# Would include accounts whose password does not expire, therefore not expired.
# Includes pwdLastSet = 0
$MaxPwdAgeDays = (Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty MaxPasswordAge).TotalDays
$PwdExpiredDate = (Get-Date).AddDays($MaxPwdAgeDays * -1)
$PwdExpiredDateFileTime = $PwdExpiredDate.ToFileTimeUTC()
Get-ADUser -Filter "pwdLastSet -lt $PwdExpiredDateFileTime"

# Show me the date the password was last set
Get-ADUser -Filter "pwdLastSet -lt $PwdExpiredDateFileTime" -Properties pwdLastSet |
    Select-Object DistinguishedName, pwdLastSet, `
        @{name='pwdLastSetConverted';expression={[datetime]::fromFileTime($_.pwdlastset)}} |
    Sort-Object pwdLastSetConverted



# Shows actually expired accounts (past date on account)
Search-ADAccount -AccountExpired

