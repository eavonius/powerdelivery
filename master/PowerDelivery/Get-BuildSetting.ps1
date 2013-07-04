<#
.Synopsis
Gets a environment setting from the .csv file for the environment 
the currently executing build is targeting for deployment.

.Description
Gets a environment setting from the .csv file for the environment 
the currently executing build is targeting for deployment.

.Parameter name
The name of the setting from the .csv file to get.

.Outputs
The value of the setting from the .csv file for the setting that was 
requested.

.Example
$webServerName = Get-BuildSetting WebServerName
#>
function Get-BuildSetting {
    [CmdletBinding()]
    param([Parameter(Position=0,Mandatory=1)][string] $name)

	if (!$powerdelivery.is_yaml) {

		ForEach ($envVar in $powerdelivery.envConfig) {
			if ($envVar.Name -eq $name) {
				return $envVar.Value
			}
		}
	}
	else {
		$setting = $powerdelivery.envConfig[$name]
		
		if ($setting) {
			return $setting
		}
	}
	
	throw "Couldn't find build setting '$name'"
}