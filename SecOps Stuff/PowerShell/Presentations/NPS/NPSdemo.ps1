#region Exploring PowerShell

(Get-Command).count

Get-Command *process*

Get-Help Get-Process -Full

Get-Help Get-Process -Examples

Get-Process -Name PowerShell

Update-Help

#endregion

#region Getting Information
Get-WmiObject -class Win32_LogicalDisk

Get-WmiObject -class Win32_LogicalDisk | Where-Object DriveType -eq 3

Get-WmiObject -class Win32_LogicalDisk -Filter "DriveType=3"

(Get-WmiObject -class Win32_LogicalDisk -Filter "DriveType=3").FreeSpace / 1GB

#endregion

#region Making Changes
New-Item -Path $env:SystemDrive\NPS -Name NPS -ItemType Directory

New-Item -Path $env:SystemDrive\NPS -Name NPSfile.txt -ItemType File -Value 'Test File'

Get-Content -Path $env:SystemDrive\NPS\NPSfile.txt

Set-Content -Path $env:SystemDrive\NPS\NPSfile.txt -Value 'PowerShell'

Get-Content -Path $env:SystemDrive\NPS\NPSfile.txt

#endregion

#region Introduction to the Scripting Language

### Variables
$var = 'variable'
$number = 1
$numberArray = 1,2,3,4,5,6
$stringArray = 'a','b','c','d'

### Quotation Marks
$singleQuotes = 'Use for text without variables'
$doubleQuotes = "Use when placing a $var in quotes"

### Object Members Variables
$proc = Get-Process | Sort-Object -Descending
$proc | Get-Member
$name = $proc[0].ProcessName
$name.ToUpper()

### Parentheses
Get-Process (Get-Content -Path C:\NPS\NPSfile.txt)

### Operators
'PowerShell' -eq 'PowerShell'
'NPS' -ne 'PowerShell'

help *operators*

### If construct

### Foreach loop
$collection = 'PowerShell','Is','Awesome'

foreach ($item in $collection)
{
    Write-Host $item -ForegroundColor Green
}
#endregion

#region Simple Scripts and Functions

### Scripting

$Password = Read-Host -AsSecureString
New-LocalUser -Name localadmin -Description 'New Local Admin' -AccountNeverExpires -Password $Password -PasswordNeverExpires
Add-LocalGroupMember -Group Administrators -Member localadmin
Get-LocalGroupMember -Group administrators

### Functions

function New-LocalAdmin ($Name) {
    Write-Output "Please Enter Password"
    $Password = Read-Host -AsSecureString
    
    Write-Output "Creating new user [$Name]"
    New-LocalUser -Name $Name -Description 'New Local Admin' -AccountNeverExpires -Password $Password -PasswordNeverExpires
    
    Write-Output "Adding [$Name] to [Administrators] group"
    Add-LocalGroupMember -Group Administrators -Member $Name
}

#endregion
