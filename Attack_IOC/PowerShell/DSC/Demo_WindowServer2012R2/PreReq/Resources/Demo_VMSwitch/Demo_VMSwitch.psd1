#
# Module manifest for module 'MSFT_VMSwitch'
#
# Generated on: 12/17/2012
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'a280c1e4-9b60-4074-b280-36aede287b1f'
# Author of this module
Author = 'Microsoft Corporation'
# Company or vendor of this module
CompanyName = 'Microsoft Corporation'
 # Copyright statement for this module
Copyright = '(c) 2012 Microsoft Corporation. All rights reserved.'
# Description of the functionality provided by this module
Description = 'This Module is used to support the execution of query, install & uninstall functionalities on Windows features through Get, Set and Test API on the DSC managed nodes.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'
# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @("Demo_VMSwitch.psm1")
# Functions to export from this module
FunctionsToExport = @("Get-TargetResource", "Set-TargetResource", "Test-TargetResource")

# Cmdlets to export from this module
#CmdletsToExport = '*'

# HelpInfo URI of this module

# HelpInfoURI = ''
}