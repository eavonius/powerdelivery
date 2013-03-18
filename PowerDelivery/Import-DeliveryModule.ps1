<#
.Synopsis
Imports a delivery module for use by a delivery build script.

.Description
Imports a delivery module for use by a delivery build script. This causes 
powerdelivery to try and find functions that match the following syntax 
in any loaded PowerShell modules:

Invoke-<ModuleName>DeliveryModule<Stage>

Where "ModuleName" is the value passed to the name parameter of this 
function, and "Stage" is any of the delivery block names ("Init", "Commit", 
"SetupEnvironment", "Deploy" etc.) prefixed with "Pre" to run before the 
code in the delivery build script doing the import, or "Post" to run after.

.Parameter name
The name of the delivery module to import functions for.

.Example
Import-DeliveryModule MSBuild
#>
function Import-DeliveryModule {
	[CmdletBinding()]
	param([Parameter(Position=0,Mandatory=1)][string] $name)
	
	$functionName = "Initialize-$($name)DeliveryModule"
	
	if (Get-Command $functionName -ErrorAction SilentlyContinue) {
		& $functionName
		$powerdelivery.deliveryModules += $name
	}
	else {
		throw "Delivery Module $name could not be loaded. Unable to find function $functionName in loaded PowerShell modules."
	}
}