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

    $buildEnvironment = Get-BuildEnvironment

    if (!$powerdelivery.deployShares.ContainsKey($computerName)) {

        $driveLetter = $powerdelivery.deployDriveLetter

        New-RemoteShare -computerName $computerName -shareName "PowerDelivery" -shareDirectory "$($driveLetter):\PowerDelivery" | Out-Host

        $buildName = Get-BuildName
        $buildNumber = Get-BuildNumber

        $deployPath = "\\$computerName\PowerDelivery"
        $buildPath = "$deployPath\$buildName"

        mkdir $buildPath -Force | Out-Null

        $buildMatches = "$($powerdelivery.scriptName) - $($buildEnvironment)*"

        $prevBuildCount = (gci -Directory $deployPath | where-object -Property Name -Like $buildMatches).count

        if ($prevBuildCount -gt 5) {

            Write-Host "Removing builds older than newest 5 on $computerName for $buildMatches"

            $numberToDelete = $prevBuildCount - 5
            
            gci -Directory $deployPath | where-object -Property Name -Like $buildMatches | Sort-Object -Property LastWriteTime | select -first $numberToDelete | Remove-Item -Force -Recurse | Out-Null
        }

        $localDeployPath = $deployPath -replace "\\\\$computerName", "$($driveLetter):"
        $localAliasPath = [System.IO.Path]::Combine($localDeployPath, "$($powerdelivery.scriptName) - $($buildEnvironment)")
        $localBuildPath = [System.IO.Path]::Combine($localDeployPath, $buildName)

        Invoke-Command -ComputerName $computerName -ScriptBlock {
            if ((Test-Path -Path $using:localAliasPath)) {
                & cmd /c "rmdir ""$using:localAliasPath"""
            }

            & cmd /c "mklink /J ""$using:localAliasPath"" ""$using:localBuildPath""" | Out-Null
        }

        $powerdelivery.deployShares.Add($computerName, $buildPath)
    }
    $powerdelivery.deployShares[$computerName]
}