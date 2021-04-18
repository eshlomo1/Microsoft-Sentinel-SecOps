#ISE Shortcuts
https://technet.microsoft.com/en-us/library/jj984298.aspx

#Increase PowerShell Font Size
$psISE.Options.Zoom = 145

#Goes to Conosle
Ctrl + D

#Goes to Script Pane
Ctrl + I

#Return limited resutls
Get-aduser -filter * -properties * -resultsetsize 1  

#Clip copies output from a cmdlet
Ipconfig | clip

#Ctrl + alt to select multipule lines

#Removing characters from end of variable
$string = $string -replace ".$"

#Add or Removing characters from start of variable
$var = "Blah" 
$var = $var.Insert(0,"01")

#Open scripts within ISE
psedit .\script1.

#Ctrl + space to call out intlisense

#v4 where
$x = gps 
$x.where{$_.Name -like "*ss"}

$x = gps 
$x.where{$_.Name -like "*ss"}.Name

##Awesome PS module | show-object
Install-Module PowerShellCookbook
gps | show-object
