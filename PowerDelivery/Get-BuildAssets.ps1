<#
.Synopsis
Copies build assets from the drop location to the build working directory.

.Description
Copies build assets from the drop location to the build working directory. You should specify 
relative paths for this command.

.Parameter path
The relative remote path of assets at the drop location that should be copied locally.

.Parameter destination
The relative local path to copy the assets to.

.Parameter filter
Optional. A filter for the file extensions that should be included.

.Example
Get-BuildAssets "SomeDir\SomeFiles" "SomeDir" -Filter *.*
#>
function Get-BuildAssets {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)][string] $path,
		[Parameter(Position=1,Mandatory=1)][string] $destination,
		[Parameter(Position=2,Mandatory=0)][string] $filter	= $null
	)

	$currentDirectory = Get-Location
	$dropLocation = Get-BuildDropLocation
	
	$sourcePath = Join-Path $dropLocation $path
	$destinationPath = Join-Path $currentDirectory $destination
	
	mkdir -Force $destinationPath | Out-Null
	
	copy -Filter $filter -Force -Path $sourcePath -Destination $destinationPath
}