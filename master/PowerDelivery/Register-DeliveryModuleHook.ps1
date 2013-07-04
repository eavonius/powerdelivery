<#
.Synopsis
Registers a hook function that will be called before or after 
a function in a delivery build script.

.Description
Use this function in a powerdelivery delivery module to register a function 
so that it gets called before or after a function in a delivery build script. 
For example, you can write code in a module that runs before the "Compile" function 
in the importing script.

.Parameter function
The name of the function to hook prefixed with "Pre" or "Post" to have the 
hook code run before or after the importing script's function respectively.

.Example
Register-DeliveryModuleHook "PreCompile" {
	// Your code here
}
#>
function Register-DeliveryModuleHook {
	[CmdletBinding()]
	param(
		[ValidateSet("PreInit", "PostInit", 
					 "PreCompile", "PostCompile", 
					 "PreSetupEnvironment", "PostSetupEnvironment", 
					 "PreTestEnvironment", "PostTestEnvironment", 
					 "PreDeploy", "PostDeploy", 
					 "PreTestAcceptance", "PostTestAcceptance", 
					 "PreTestUnits", "PostTestUnits", 
					 "PreTestCapacity", "PostTestCapacity")]
		[Parameter(Position=0,Mandatory=1)][string] $function,
		[Parameter(Position=1,Mandatory=1)][scriptblock] $action
	)
	
	$powerdelivery.moduleHooks[$function] += $action
}