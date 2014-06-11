<#
.Synopsis
Retrieves the local path on a remote computer to deploy files into.

.Description
Retrieves the local path on a remote computer to deploy files into. This path 
will be a subdirectory named after the build number, nested within another 
directory named after the build.

.Parameter computerName
The computer to retrieve the deploy path for.

.Parameter driveLetter
Optional. The drive letter upon which to deploy files. Defaults to "C"

.Example
$deployPath = Get-ComputerLocalDeployPath
#>
function Get-ComputerLocalDeployPath {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=0)][string] $driveLetter = $powerdelivery.deployDriveLetter
    )

    $remoteDeployPath = Get-ComputerRemoteDeployPath $computerName -DriveLetter $powerdelivery.deployDriveLetter
    $remoteDeployPath -replace "\\\\$computerName", "$($driveLetter):"
}