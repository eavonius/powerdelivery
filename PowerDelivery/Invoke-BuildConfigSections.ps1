<#
.Synopsis
Calls the Invoke-BuildConfigSection cmdlet once for each entry in a hash. 

.Description
Calls the Invoke-BuildConfigSection cmdlet once for each entry in a hash. Use this to do 
work on all nested entries in a section of YAML from the build environment configuration.

.Parameter sections
hash - Each value of the hash will be passed to Invoke-BuildConfigSection cmdlet.

.Parameter cmdlet
string - The name of the cmdlet to invoke.

.Example
In th example below, there is a YAML configuration section named "MSBuild" with YAML sections 
below it. Each entry below it has settings that match the arguments of the "Invoke-MSBuild" cmdlet.

$msBuildSection = Get-BuildSetting MSBuild
Invoke-BuildConfigSections $msBuildSection Invoke-MSBuild
#>
function Invoke-BuildConfigSections {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $sections,
		[Parameter(Position=1,Mandatory=1)][string] $cmdlet
	)
	
	$sections.Keys | % {
		$section = $sections[$_]
		Invoke-BuildConfigSection $section $cmdlet
	}
}