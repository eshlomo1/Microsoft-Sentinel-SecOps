#Requires -RunAsAdministrator

<#-----------------------------------------------------------------------------
Ashley McGlone, Microsoft Premier Field Engineer
http://aka.ms/GoateePFE
February 2015

This script creates a template for a new DSC composite resource.

See this blog post for more information on DSC composite resources:
http://blogs.msdn.com/b/powershell/archive/2014/02/25/reusing-existing-configuration-scripts-in-powershell-desired-state-configuration.aspx

Feel free to modify to your own needs.

-------------------------------------------------------------------------------
LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.
 
This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at http://www.microsoft.com/info/cpyright.htm.
-----------------------------------------------------------------------------#>

<#
.SYNOPSIS
Creates a PowerShell Desired State Configuration composite resource template.
.DESCRIPTION
This script creates a template for a new DSC composite resource.
- Creates the folder structure
- Creates the psd1 and psm1 files
- Supplies template text
- Lists the output
- Opens the template files in the ISE
.PARAMETER ModuleRoot
The PSModulePath where you want the module created.
.PARAMETER ModuleName
Name of the parent module to hold the composite resources
.PARAMETER ResourceName
Name of the individual composite resource
.EXAMPLE
Create a single composite resource:
New-DSCCompositeResource -ModuleName contosoCompositeResources -ResourceName contosoBaseBuildCompositeResource
.EXAMPLE
Create multiple composite resources:
New-DSCCompositeResource -ModuleName contosoCompositeResources -ResourceName contosoBaseBuildCompositeResource
New-DSCCompositeResource -ModuleName contosoCompositeResources -ResourceName contosoAppTierCompositeResource
New-DSCCompositeResource -ModuleName contosoCompositeResources -ResourceName contosoWebTierCompositeResource
.LINK
http://aka.ms/GoateePFE
#>
Function New-DSCCompositeResource {
Param(
    [string]
    [parameter()]
    [ValidateScript({Test-Path $_})]
    $ModuleRoot = "$($ENV:ProgramFiles)\WindowsPowerShell\Modules",
    [parameter(Mandatory)]
    [string]
    $ModuleName,
    [parameter(Mandatory)]
    [string]
    $ResourceName
)
    # Root Module
    If (-not (Test-Path -Path "$ModuleRoot\$ModuleName")) {
        New-Item -Path "$ModuleRoot\$ModuleName" -ItemType File -Name "$ModuleName.psm1" -Force -Value "### This file intentionally left blank ###" | Out-Null
        New-ModuleManifest -Path "$ModuleRoot\$ModuleName\$ModuleName.psd1" -RootModule "$ModuleRoot\$ModuleName\$ModuleName.psm1"
    } Else {
        Write-Warning "Module $ModuleName already exists."
    }

    # Resource
    $ResourcePath = "$ModuleRoot\$ModuleName\DSCResources\$ResourceName"
    If (-not (Test-Path -Path $ResourcePath)) {
        $CompositeCode = @"
Configuration $ResourceName {
Param()

    ### Insert composite resource code here
    ### NOTE: Composite resources do not include a NODE block

}
"@
        New-Item -Path $ResourcePath -ItemType File -Name "$ResourceName.schema.psm1" -Force -Value $CompositeCode | Out-Null
        New-ModuleManifest -Path "$ResourcePath\$ResourceName.psd1" -RootModule "$ResourcePath\$ResourceName.schema.psm1"

        # Example
        $Example = @"
### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName $ModuleName

    Node localhost {

        $ResourceName bbbbbb {
            property = value
        }

    }
}
"@
        New-Item -Path "$ResourcePath\Examples" -ItemType File -Name "$($ResourceName)_Example.ps1" -Force -Value $Example | Out-Null

        Get-ChildItem $ResourcePath -Recurse

        ISE "$ResourcePath\$ResourceName.schema.psm1"
        ISE "$ResourcePath\Examples\$($ResourceName)_Example.ps1"

    } Else {
        Write-Warning "Composite resource $ResourceName already exists."
    }

}
