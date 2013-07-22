<#
.Synopsis
Gets YAML configuration used for the build. The values are in a hash that contains the result of 
merging the target environment (Commit, Test, or Production etc.) and any entries in the "Shared" 
configuration. Entries in the target environment overwrite the shared one.

.Description
Gets YAML configuration used for the build. The values are in a hash that contains the result of 
merging the target environment (Commit, Test, or Production etc.) and any entries in the "Shared" 
configuration. Entries in the target environment overwrite the shared one.

.Outputs
The YAML configuration object containing build configuration settings.

.Example
$buildConfig = Get-BuildConfig
#>
function Get-BuildConfig {
	[CmdletBinding()]
	param()
	return $powerdelivery.config
}