<#
.Synopsis
Retrieves the UNC path on a remote computer to deploy files into.

.Description
Retrieves the UNC path on a remote computer to deploy files into. This path 
will be a subdirectory named after the build number, nested within another 
directory named after the build.

.Parameter computerName
The computer to retrieve the deploy path for.

.Parameter driveLetter
Optional. The drive letter upon which to deploy files. Defaults to "C"

.Example
$deployPath = Get-ComputerRemoteDeployPath
#>
function Get-ComputerRemoteDeployPath {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=0)][string] $driveLetter = $powerdelivery.deployDriveLetter
    )

    $buildEnvironment = Get-BuildEnvironment

    if (!$powerdelivery.deployShares.ContainsKey($computerName)) {

        if (!$computerName.StartsWith("localhost"))
        {
            New-RemoteShare -computerName $computerName -shareName "PowerDelivery" -shareDirectory "$($driveLetter):\PowerDelivery" | Out-Host
        }

        $buildName = Get-BuildName
        $buildNumber = Get-BuildNumber

        $deployPath = "\\$computerName\PowerDelivery"

        if ($computerName.StartsWith("localhost"))
        {
            $deployPath = "$($driveLetter):\PowerDelivery"

            if (!(Test-Path $deployPath))
            {
                mkdir -Force $deployPath | Out-Null
            }
        }

        $buildPath = "$deployPath\$buildName"

        mkdir $buildPath -Force | Out-Null

        $buildMatches = "$($powerdelivery.scriptName) - $($buildEnvironment)*"

        $prevBuildCount = (gci -Directory $deployPath | where-object -Property Name -Like $buildMatches).count

        if ($prevBuildCount -gt 5) {

            Write-Host "Removing builds older than newest 5 on $computerName for $buildMatches"

            $numberToDelete = $prevBuildCount - 5
            
            gci -Directory $deployPath | where-object -Property Name -Like $buildMatches | Sort-Object -Property LastWriteTime | select -first $numberToDelete | Remove-Item -Force -Recurse | Out-Null
        }

        $localDeployPath = $deployPath

        if (!$computerName.StartsWith("localhost"))
        {
            $localDeployPath = $deployPath -replace "\\\\$computerName", "$($driveLetter):"
        }

        $localAliasPath = [System.IO.Path]::Combine($localDeployPath, "$($powerdelivery.scriptName) - $($buildEnvironment)")
        $localBuildPath = [System.IO.Path]::Combine($localDeployPath, $buildName)

        $invokeArgs = @{
            "ArgumentList" = @($localAliasPath, $localBuildPath);
            "ScriptBlock" = {
                param($aliasPath, $buildPath)
                if ((Test-Path -Path $localAliasPath)) {
                    & cmd /c "rmdir ""$aliasPath"""
                }

                & cmd /c "mklink /J ""$aliasPath"" ""$buildPath""" | Out-Null
            }
        }

        if (!$computerName.StartsWith("localhost")) {
            $invokeArgs.Add("ComputerName", $computerName)
        }

        Invoke-Command @invokeArgs

        $powerdelivery.deployShares.Add($computerName, $buildPath)
    }
    $powerdelivery.deployShares[$computerName]
}