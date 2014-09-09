function Publish-MasterDataServices {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $package,
        [Parameter(Position=2,Mandatory=0)][string] $version,
        [Parameter(Position=3,Mandatory=0)][string] $credentialUserName,
        [Parameter(Position=4,Mandatory=0)][string] $mdsDeployPath = "C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\"
    )

    $logPrefix = "Publish-MasterDataServices:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        "$logPrefix Publishing $package to up Master Data Services on $computerName"

        $dropLocation = Get-BuildDropLocation

        # Allow credentials to travel from remote computer to TFS server
        #
        $dropUri = New-Object -TypeName System.Uri -ArgumentList $dropLocation
        
        if ($dropUri.IsUnc) {
            
            $dropHost = $dropUri.Host
            
            $remoteComputer = [System.Net.Dns]::GetHostByName("$dropHost").HostName

            Add-RemoteCredSSPTrustedHost $curComputerName $remoteComputer
        }

        $invokeArgs = @{
            "ArgumentList" = @($package, $version, $mdsDeployPath, $dropLocation, $logPrefix);
            "ScriptBlock" = {
                param($varPackage, $varVersion, $varMdsDeployPath, $varDropLocation, $varLogPrefix)

                $tempOutputDirectory = Join-Path $env:TEMP "PowerDelivery"
                
                # Create the subdirectory of the package path if one was specified
                #
                $packagePath = [System.IO.Path]::GetDirectoryName("$varPackage")
                if ($packagePath) {
                    $tempSubPath = Join-Path "$tempOutputDirectory" "$packagePath"
                    if (!(Test-Path -Path $tempSubPath)) {
                        New-Item -ItemType Directory -Path "$tempSubPath" | Out-Null
                    }
                }
                
                $tempPackageFile = Join-Path "$tempOutputDirectory" "$varPackage"

                # Delete the prior temporary package if one exists
                #
                if (Test-Path -Path "$tempPackageFile") {
                    Remove-Item -Path "$tempPackageFile" -Force | Out-Null
                }

                $remotePackage = Join-Path $varDropLocation $varPackage

                Copy-Item -Path $remotePackage -Destination $tempPackageFile

                # NOTE: The TFS Build Service account must have been given function and 
                # model permission to MDS so this command will succeed.
                #
                $mdsDeployPath = Join-Path $varMdsDeployPath "MDSModelDeploy"

                $mdsDeployCommand = """$mdsDeployPath"" deployupdate -package ""$tempPackageFile"""

                if ($varVersion) {
                    $mdsDeployCommand += " -version ""$varVersion"""
                }

                Write-Host "$varLogPrefix $mdsDeployCommand"
                Invoke-Expression "& $mdsDeployCommand"
            };
            "ErrorAction" = "Stop"
        }

        Add-CommandCredSSP $curComputerName $invokeArgs $credentialUserName

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "Master Data Services: $package -> $computerName"
    }
}