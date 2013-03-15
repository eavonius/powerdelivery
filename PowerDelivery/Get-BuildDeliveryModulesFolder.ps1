<#
.Synopsis
Gets the local directory relative to which delivery modules can load .csv files for 
configuration.

.Description
Gets the local directory relative to which delivery modules can load .csv files for 
configuration. This function is used by delivery modules and should not be called 
directly by a delivery pipeline script.

.Outputs
The directory from which delivery modules can load .csv files for configuration.

.Example
$deliveryModulesFolder = Get-BuildDeliveryModulesFolder
#>
function Get-BuildDeliveryModulesFolder {
	[CmdletBinding()]
	param()
	return $powerdelivery.deliveryModulesFolder
}