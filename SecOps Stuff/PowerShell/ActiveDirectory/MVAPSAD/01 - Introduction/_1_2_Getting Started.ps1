break



# View ADWS service, ports, firewall rules
# Import the module (v2)
# List cmdlets
# Basic AD cmdlets
# AD: provider
# Import over a PSSession




Get-Module -ListAvailable

# AD Web Service
Get-Service ADWS
Get-NetTCPConnection -LocalPort 9389
Get-NetFirewallRule -DisplayName "Active Directory Web Services*" | Format-List Name, DisplayName

Get-Service ADWS -ComputerName DC1.tailspintoys.local




# This is the same process used to import and understand any module:
# - List
# - Import
# - Get-Command
get-module -listavailable
import-module activedirectory
get-command -module activedirectory | more



# AD Cmdlets
Import-Module ActiveDirectory
Get-Command -Module ActiveDirectory | Format-Wide
Get-Command -Module ActiveDirectory | Measure-Object

# AD DS Deployment Cmdlets
Import-Module ADDSDeployment
Get-Command -Module ADDSDeployment | Format-Wide
Get-Command -Module ADDSDeployment | Measure-Object


# Active Directory for Windows PowerShell About Help Topics
# http://technet.microsoft.com/en-us/library/hh531525(v=ws.10).aspx
Get-Help about_ActiveDirectory
Get-Help about_ActiveDirectory_Filter
Get-Help about_ActiveDirectory_Identity
Get-Help about_ActiveDirectory_ObjectModel


#get domain/forest info
get-addomain | fl *
get-adforest | fl *





# Demo the AD: drive
get-psdrive
cd AD:
dir
# Type "CD " and use tab completion
cd '.\DC=wingtiptoys,DC=local'
dir
dir -recurse
# Use Tab complete
cd .\CN=Users
dir
cd c:








# How to use ActiveDirectory module cmdlets from Windows 7 without the RSAT installed.
# -How to use 2012 ActiveDirectory module cmdlets from Windows 7.
# -How to use 2008 R2 ActiveDirectory module cmdlets from Windows 7.
# Must have WMF 3.0/PowerShell 3.0 installed on Windows 7 machine.

# No AD module installed.  No RSAT.
Get-Module -ListAvailable

# Import from 2012 in same domain already logged in with admin credentials.
# Requires Execution Policy above restricted.
$c = New-PSSession -ComputerName cvdc1
Import-Module ActiveDirectory -PSSession $c

# As one line:
Import-Module ActiveDirectory -PSSession (New-PSSession -ComputerName cvdc1)

# Check out the cmdlets
Get-Module
# Notice the Path and Description properties of the module tell where it comes from
Get-Module ActiveDirectory | Format-List
Get-Command -Module ActiveDirectory
Get-ADForest

# Note that objects returned are Deserialized as with any PSSession data returned
Get-ADForest | Get-Member
<#
PS C:\Users\administrator> Get-ADForest | Get-Member

   TypeName: Deserialized.Microsoft.ActiveDirectory.Management.ADForest

Name                  MemberType   Definition                                                                                               
----                  ----------   ----------                                                                                               
ToString              Method       string ToString(), string ToString(string format, System.IFormatProvider formatProvider), string IForm...
PSComputerName        NoteProperty System.String PSComputerName=cvdc1                                                                       
PSShowComputerName    NoteProperty System.Boolean PSShowComputerName=False                                                                  
RunspaceId            NoteProperty System.Guid RunspaceId=dddefa01-ed12-499c-91f0-2a0928027d11                                              
ApplicationPartitions Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
CrossForestReferences Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
DomainNamingMaster    Property     System.String {get;set;}                                                                                 
Domains               Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
ForestMode            Property     System.String {get;set;}                                                                                 
GlobalCatalogs        Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
Name                  Property     System.String {get;set;}                                                                                 
PartitionsContainer   Property     System.String {get;set;}                                                                                 
RootDomain            Property     System.String {get;set;}                                                                                 
SchemaMaster          Property     System.String {get;set;}                                                                                 
Sites                 Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
SPNSuffixes           Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
UPNSuffixes           Property     Deserialized.Microsoft.ActiveDirectory.Management.ADPropertyValueCollection {get;set;}                   
#>


# Compare the output of this same command run natively on any DC with PowerShell
<#
PS C:\Users\administrator.COHOVINEYARD> Get-ADForest | Get-Member


   TypeName: Microsoft.ActiveDirectory.Management.ADForest

Name                  MemberType            Definition
----                  ----------            ----------
Contains              Method                bool Contains(string propertyName)
Equals                Method                bool Equals(System.Object obj)
GetEnumerator         Method                System.Collections.IDictionaryEn...
GetHashCode           Method                int GetHashCode()
GetType               Method                type GetType()
ToString              Method                string ToString()
Item                  ParameterizedProperty Microsoft.ActiveDirectory.Manage...
ApplicationPartitions Property              Microsoft.ActiveDirectory.Manage...
CrossForestReferences Property              Microsoft.ActiveDirectory.Manage...
DomainNamingMaster    Property              System.String DomainNamingMaster...
Domains               Property              Microsoft.ActiveDirectory.Manage...
ForestMode            Property              System.Nullable`1[[Microsoft.Act...
GlobalCatalogs        Property              Microsoft.ActiveDirectory.Manage...
Name                  Property              System.String Name {get;}
PartitionsContainer   Property              System.String PartitionsContaine...
RootDomain            Property              System.String RootDomain {get;}
SchemaMaster          Property              System.String SchemaMaster {get;}
Sites                 Property              Microsoft.ActiveDirectory.Manage...
SPNSuffixes           Property              Microsoft.ActiveDirectory.Manage...
UPNSuffixes           Property              Microsoft.ActiveDirectory.Manage...
#>

# Implicit remoting will rebuild the session if it gets dropped.
# Notice the message displayed when restoring the session.
Get-PSSession | Remove-PSSession
Get-ADDomain -Server cvdc1
Get-PSSession

# From Win7 machine using imported 2012 DC cmdlets to 2003 DC running ADWS in a trusted forest
Get-Service ADWS -ComputerName DC1.tailspintoys.local
# Notice OperatingSystemVersion is 5.2 (2003)
Get-ADDomainController -Server DC1.tailspintoys.local
# Create a user
New-ADUser GeekReady -Description "Hey, look at me! I'm on the big screen!" -Server DC1.tailspintoys.local
# Go to that DC and view it in the GUI
Get-ADUser GeekReady -Server DC1.tailspintoys.local | Select-Object distinguishedName
Remove-ADUser GeekReady -Server DC1.tailspintoys.local -Confirm:$false
# Now use a 2012 AD cmdlet
Get-ADReplicationSubnet -Filter * -Server DC1.tailspintoys.local

# From Win7 machine using imported 2012 DC cmdlets to 2008 R2 DC running ADWS in a trusted forest
Get-Service ADWS -ComputerName DCA.wingtiptoys.local
# Notice OperatingSystemVersion is 6.1 (2008 R2)
Get-ADDomainController -Server DCA.wingtiptoys.local
# Now use a 2012 AD cmdlet
Get-ADReplicationSubnet -Filter * -Server DCA.wingtiptoys.local


# Clean up
Get-Module ActiveDirectory | Remove-Module
Get-PSSession | Remove-PSSession



# Import from 2008 R2 in a different forest using credentials.
# This will get the 2008R2 cmdlets.
$wtcred = Get-Credential wingtiptoys.local\administrator
$wtsess = New-PSSession -ComputerName dca.wingtiptoys.local -Credential $wtcred
Import-Module ActiveDirectory -PSSession $wtsess
Get-Module
Get-Command -Module ActiveDirectory
Get-ADForest

