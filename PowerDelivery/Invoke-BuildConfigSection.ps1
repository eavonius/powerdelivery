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
			$sectionValue = $section[$_]
			if ($sectionValue.GetType().Name -ne 'Hashtable' -and $sectionValue.StartsWith(":")) {
				$present = $sectionValue.Substring(1)
				$isPresent = [boolean]$present
				$switchParameter = New-Object System.Management.Automation.SwitchParameter -ArgumentList @($isPresent)
				$invokeArgs.Add($_, $switchParameter)
			}
			else {
				$invokeArgs.Add($_, $section[$_])	
			}
		}
	}
	
	$outArgs = $invokeArgs | Out-String
	#Write-Host "$cmdlet $outArgs"

	Invoke-Expression "& $cmdlet @invokeArgs"
}