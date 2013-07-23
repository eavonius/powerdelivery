<#
.Synopsis
Invokes a PowerShell cmdlet passing a section of YAML from the build environment configuration as arguments to it.

.Description
Invokes a PowerShell cmdlet passing a section of YAML from the build environment configuration as arguments to it.

.Parameter section
hash - Each value of the hash will be passed to the cmdlet as arguments.

.Parameter cmdlet
string - The name of the cmdlet to invoke.

.Example
In the example below, there is a YAML configuration section named "Database" with 
settings that match the arguments of the "Invoke-Roundhouse" cmdlet.

$databaseSection = Get-BuildSetting Database
Invoke-BuildConfigSection $databaseSection Invoke-Roundhouse 
#>
function Invoke-BuildConfigSection {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $section,
		[Parameter(Position=1,Mandatory=1)] $cmdlet
	)
	
	$invokeArgs = @{}

	if ($section.Keys) {
		$section.Keys | % {
			$invokeArgs.Add($_, $section[$_])
		}
	}
	
	Invoke-Expression "& $cmdlet @invokeArgs"
}