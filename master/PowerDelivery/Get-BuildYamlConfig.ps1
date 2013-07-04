<#
.Synopsis
Gets the YAML configuration file used for the build. Returns null if a .csv file 
was used.

.Description
Gets the YAML configuration file used for the build. Returns null if a .csv file 
was used.

.Outputs
The YAML configuration object used by delivery modules to get settings.

.Example
$yamlConfig = Get-BuildYamlConfig
#>
function Get-BuildYamlConfig {
	[CmdletBinding()]
	param()
	return $powerdelivery.yamlConfig
}