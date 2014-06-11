function Deploy-BuildAssets {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)][string] $computerName,
		[Parameter(Position=1,Mandatory=1)][string] $path,
		[Parameter(Position=2,Mandatory=1)][string] $destination,
		[Parameter(Position=3,Mandatory=0)][string] $filter	= "*.*",
		[Parameter(Position=4,Mandatory=0)][switch] $recurse = $false,
		[Parameter(Position=5,Mandatory=0)][string] $driveLetter = $powerdelivery.deployDriveLetter
	)
	
	$logPrefix = "Deploy-BuildAssets:"
	
	$computerNames = $ComputerName -split "," | % { $_.Trim() }
	
	$dropLocation = Get-BuildDropLocation
	$dropSource = Join-Path $powerdelivery.deployDir $path
	
	foreach ($curComputerName in $computerNames) {
	
		$remoteDeployPath = Get-ComputerRemoteDeployPath $curComputerName $driveLetter
        $remoteDestinationPath = Join-Path $remoteDeployPath $destination
		
		mkdir -Force $remoteDestinationPath | Out-Null
		
		Copy-Robust $dropSource $remoteDestinationPath -filter $filter -recurse:$recurse.IsPresent
	}
}