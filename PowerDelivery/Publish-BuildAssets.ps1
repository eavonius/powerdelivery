function Publish-BuildAssets {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)][string] $path,
		[Parameter(Position=1,Mandatory=1)][string] $destination,
		[Parameter(Position=2,Mandatory=0)][string] $filter	= $null
	)

	$currentDirectory = Get-Location
	$dropLocation = Get-BuildDropLocation
	
	$sourcePath = Join-Path $currentDirectory $path
	$destinationPath = Join-Path $dropLocation $destination
	
	mkdir -Force $destinationPath | Out-Null
	
	copy -Filter $filter -Force -Path $sourcePath -Destination $destinationPath
}