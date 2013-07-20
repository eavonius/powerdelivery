<#
.Synopsis
Gets a configuration setting from the YML files for the environment 
the currently executing build is targeting for deployment.

.Description
Gets a configuration setting from the YML files for the environment 
the currently executing build is targeting for deployment.

.Parameter name
The name of the setting from the YML file to get.

.Outputs
The value of the setting from the YML file for the setting that was 
requested.

.Example
$webServerName = Get-BuildSetting WebServerName
#>
function Get-BuildSetting {
    [CmdletBinding()]
    param([Parameter(Position=0,Mandatory=1)][string] $name)

	if (!$powerdelivery.config.ContainsKey($name)) {
		throw "Couldn't find build setting '$name'"
	}

	$powerdelivery.config[$name]
}