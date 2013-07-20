function Invoke-ConfigSections {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $sections,
		[Parameter(Position=1,Mandatory=1)] $cmdlet
	)
	
	$sections.Keys | % {
		$section = $sections[$_]
		Invoke-ConfigSection $section $cmdlet
	}
}