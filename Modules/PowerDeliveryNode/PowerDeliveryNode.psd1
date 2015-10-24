<# PowerDeliveryNode.psd1

Manifest for PowerShell module.

http://www.powerdelivery.io
#>

@{
ModuleToProcess = 'PowerDeliveryNode.psm1'

# Version number of this module.
ModuleVersion = '3.0.1'

# ID used to uniquely identify this module
GUID = '568B90B5-E030-4E55-91EC-BDA2AACB9BC9'

# Author of this module
Author = 'Jayme C Edwards'

# Company or vendor of this module
CompanyName = 'Jayme C Edwards'

# Copyright statement for this module
Copyright = 'Copyright (c) 2015 Jayme C Edwards. All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell cmdlets for use on remote nodes being deployed to with PowerDelivery 3.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '3.5'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'
}
