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