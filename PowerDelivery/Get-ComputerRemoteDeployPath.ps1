<#
.Synopsis
Retrieves the UNC path on a remote computer to deploy files into.

.Description
Retrieves the UNC path on a remote computer to deploy files into. This path 
will be a subdirectory named after the build number, nested within another 
directory named after the build.

.Parameter computerName
The computer to retrieve the deploy path for.

.Example
$deployPath = Get-ComputerRemoteDeployPath
#>
function Get-ComputerRemoteDeployPath {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName
    )

    if (!$powerdelivery.deployShares.ContainsKey($computerName)) {

        $driveLetter = $powerdelivery.deployDriveLetter

        New-RemoteShare -computerName $computerName -shareName "PowerDelivery" -shareDirectory "$($driveLetter):\PowerDelivery" | Out-Host

        $buildName = Get-BuildName
        $buildNumber = Get-BuildNumber

        $deployPath = "\\$computerName\PowerDelivery\$buildName"

        mkdir $deployPath -Force | Out-Null

        $powerdelivery.deployShares.Add($computerName, $deployPath)
    }
    $powerdelivery.deployShares[$computerName]
}