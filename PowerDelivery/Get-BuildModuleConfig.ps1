<#
.Synopsis
Gets the Module configuration file used for the build. Returns null if no Modules.yml file was found.
was used.

.Description
Gets the Module configuration file used for the build. Returns null if no Modules.yml file was found. 
was used.

.Outputs
The YAML configuration object used by delivery modules to get settings.

.Example
$moduleConfig = Get-BuildModuleConfig
#>
function Get-BuildModuleConfig {
	[CmdletBinding()]
	param()
	return $powerdelivery.moduleConfig
}