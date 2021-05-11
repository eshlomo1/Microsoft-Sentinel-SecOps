break


# Find some odd user properties
(Get-ADObject -Filter 'objectClass -eq "classSchema" -and name -eq "user"' -SearchBase (Get-ADRootDSE).SchemaNamingContext -Properties *).maycontain

# OtherAttributes for properties not available as parameters
New-ADUser Ronnie -Description "I'm a test account" -OtherAttributes @{carLicense='BR549'}
Get-ADUser Ronnie -Properties carLicense

Set-ADUser Ronnie -Replace @{carLicense='OUTATIME'}
Get-ADUser Ronnie -Properties carLicense

Set-ADUser Ronnie -Add @{carLicense='A113'}
Get-ADUser Ronnie -Properties carLicense

Set-ADUser Ronnie -Clear carLicense
Get-ADUser Ronnie -Properties carLicense


Set-ADUser anlan -EmailAddress "anlan@cohovineyard.com"




Set-ADAccountControl
Set-ADAccountExpiration
Set-ADAccountPassword



Set-ADAccountControl Ronnie –PasswordNeverExpires $true

Set-ADAccountControl Ronnie –PasswordNeverExpires $false


# Account unlock

Read-Host "Enter the user account to unlock" | Unlock-ADAccount

@echo off&&powershell.exe -Command "& {Import-Module ActiveDirectory; Read-Host "Enter the user account to unlock" | Unlock-ADAccount}"

Read-Host "Enter the user account to unlock" | Unlock-ADAccount -Credential $(Get-Credential)

@echo off&&powershell.exe -Command "& {Import-Module ActiveDirectory; Read-Host "Enter the user account to unlock" | Unlock-ADAccount -Credential $(Get-Credential)}"


# Password reset

Set-ADAccountPassword (Read-Host 'User') -R

Set-ADAccountPassword ($u=Read-Host 'User') -R;Set-ADUser $u -Ch 1

Set-ADAccountPassword ($u=Read-Host 'User') -R -Cr ($c=Get-Credential);Set-ADUser $u -Ch 1 -Cr $c

Set-ADAccountPassword -Cr ($c=Get-Credential) -S ($s=Read-Host 'DC') -I ($u=Read-Host 'User') -R;Set-ADUser $u -Ch 1 -Cr $c -Server $s




# How to copy user attributes to another field with PowerShell

# Find all accounts with a Department
# Copy that value into Description
Get-ADUser -LDAPFilter '(Department=*)' -Properties Description, Department |
 Select-Object * -First 5 |
 ForEach-Object {Set-ADObject -Identity $_.DistinguishedName `
  -Replace @{Description=$($_.Department)}}

# Find all accounts with a Department
# Copy that value along with the GivenName and SurName into Description
Get-ADUser -LDAPFilter '(Department=*)' -Properties Description, Department |
 Select-Object * -First 5 |
 ForEach-Object {Set-ADObject -Identity $_.DistinguishedName `
  -Replace @{Description="$($_.GivenName) $($_.SurName) $($_.Department)"}}

# View the results
Get-ADUser -LDAPFilter '(Department=*)' -Properties Description, Department |
 Select-Object * -First 5 |
 Format-Table Name, Description, Department



# ServicePrincipalName on a computer object

Get-ADComputer CVMEMBER1 -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName

Set-ADComputer CVMEMBER1 -ServicePrincipalNames @{Add='HTTP/myapp.cvmember1.cohovineyard.com:8080'}

Get-ADComputer CVMEMBER1 -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName

Set-ADComputer CVMEMBER1 -ServicePrincipalNames @{Remove='HTTP/myapp.cvmember1.cohovineyard.com:8080'}

Get-ADComputer CVMEMBER1 -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName





#List all site links
Get-ADObject -Filter 'objectClass -eq "siteLink"' -Searchbase (Get-ADRootDSE).ConfigurationNamingContext -Property Options, Cost, ReplInterval, SiteList, Schedule | Select-Object Name, @{Name="SiteCount";Expression={$_.SiteList.Count}}, Cost, ReplInterval, @{Name="Schedule";Expression={If($_.Schedule){If(($_.Schedule -Join " ").Contains("240")){"NonDefault"}Else{"24x7"}}Else{"24x7"}}}, Options | Format-Table * -AutoSize

#Modify all site links
#Edit Replace parameters as desired
#Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{Cost=100;ReplInterval=15;Options=5} -Confirm

#Afterall this is a PowerShell blog, so let’s get to the good part.  I’ve taken you down this long-winded path for a big finish with another one-liner.  This code uses the power of the pipeline to send a GET into a SET.  We can use PowerShell to set the cost, interval, and change notification (or any combination of those attributes) of all site links at once.
#Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{Cost=100;ReplInterval=15;Options=5} 
Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{ReplInterval=15} 

#The above line of PowerShell will set all site links to cost of 100, interval of 15, and enable change notification.  If you don’t want all of those attributes set, simply remove the attributes and values you don’t want from the end of the line.  For example, this version would only change the interval to 15 minutes on all site links:
#Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{ReplInterval=15} 

#If you want to narrow the impact, then edit the Filter switch to grab a single site link or match a wildcard on the name.  Like this:
#Get-ADObject -Filter 'objectClass -eq "siteLink" –and name –like "*foo*"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Replace @{Options=5} 

#This one-liner will reset all site link schedules to 24x7:
#Get-ADObject -Filter 'objectClass -eq "siteLink" –and schedule -like "*"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext | Set-ADObject -Clear Schedule





# Groups

Get-ADGroup Legal

Add-ADGroupMember -Identity Legal -Members Ron
Add-ADGroupMember -Identity Legal -Members (Get-ADUser -Filter 'Office -eq "MVA"')

Get-ADGroup Legal -Properties Members, MemberOf
Get-ADGroup Legal -Properties Members, MemberOf | Select-Object -ExpandProperty Members
Get-ADGroupMember Legal | ogv


# Cross-domain group issues
# SEE DEMO ON DCA.WINGTIPTOYS.LOCAL

