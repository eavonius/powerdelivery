<#
.Synopsis
Retrieves the local path on a remote computer to deploy files into.

.Description
Retrieves the local path on a remote computer to deploy files into. This path 
will be a subdirectory named after the build number, nested within another 
directory named after the build.

.Parameter computerName
The computer to retrieve the deploy path for.

.Example
$deployPath = Get-ComputerLocalDeployPath
#>
function Get-ComputerLocalDeployPath {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName
    )

    $driveLetter = $powerdelivery.deployDriveLetter

    $remoteDeployPath = Get-ComputerRemoteDeployPath $computerName
    $remoteDeployPath -replace "\\\\$computerName", "$($driveLetter):"
}