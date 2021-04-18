Function Unblock-Directory { 
<#
.SYNOPSIS

Unblocks files

.DESCRIPTION

This function unblocks files that are downloaded from the internet, preventing errors upon execution.

.PARAMETER Path

The path of the directory containing locked files.

.EXAMPLE

PS C:\> Unblock-Directory -Path "C:\ScriptDownloads"

.Notes

.LINK

#>
Param(
[CmdletBinding()]

[Parameter(Mandatory=$True)]
[string]$Path

)

Get-ChildItem "$path" -Recurse | Unblock-File

}
