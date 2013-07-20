<#
.Synopsis
Gets the YAML configuration used for the build.

.Description
Gets the YAML configuration used for the build.

.Outputs
A nested hashtable of YAML configuration settings that is the result 
of merging the shared (Modules) and environment-specific configuration.

.Example
$yamlConfig = Get-BuildYamlConfig
#>
function Get-BuildYamlConfig {
	[CmdletBinding()]
	param()
	return $powerdelivery.config
}