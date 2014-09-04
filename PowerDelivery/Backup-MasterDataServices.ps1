function Backup-MasterDataServices {
    param(
        [Parameter(Position=0,Mandatory=1)] $computerName,
        [Parameter(Position=1,Mandatory=1)] $model,
        [Parameter(Position=2,Mandatory=1)] $service,
        [Parameter(Position=3,Mandatory=1)] $package,
        [Parameter(Position=4,Mandatory=0)] $credentialUserName,
        [Parameter(Position=5,Mandatory=0)] $mdsDeployPath = "C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\MDSModelDeploy"
    )
    
    $logPrefix = "Backup-MasterDataServices:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        "$logPrefix Backing up Master Data Services model $model on $computerName"

        $dropLocation = Get-BuildDropLocation

        $invokeArgs = @{
            "ArgumentList" = @($model, $service, $package, $mdsDeployPath, $dropLocation, $logPrefix);
            "ScriptBlock" = {
                param($varModel, $varService, $varPackage, $varMdsDeployPath, $varDropLocation, $varLogPrefix)

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

                # Delete the prior temporary backup if one exists
                #
                if (Test-Path -Path "$tempPackageFile") {
                    Remove-Item -Path "$tempPackageFile" -Force | Out-Null
                }

                # NOTE: The TFS Build Service account must have been given function and 
                # model permission to MDS so this command will succeed.
                #
                & $varMdsDeployPath createpackage -package $tempPackageFile -model $varModel -service $varService

                # Allow credentials to travel from remote computer to TFS server
                #
                $dropUri = New-Object -TypeName System.Uri -ArgumentList $varDropLocation
                if ($dropUri.IsUnc) {

                    $dropHost = $dropUri.Host

                    $remoteComputer = [System.Net.Dns]::GetHostByName("$dropHost").HostName

                    $credSSP = Get-WSManCredSSP

                    $computerExists = $false

                    if ($credSSP -ne $null) {
                        if ($credSSP.length -gt 0) {
                            $trustedClients = $credSSP[0].Substring($credSSP[0].IndexOf(":") + 2)
                            $trustedClientsList = $trustedClients -split "," | % { $_.Trim() }
            
                            if ($trustedClientsList.Contains("wsman/$remoteComputer")) {
                                $computerExists = $true
                            }
                        }
                    }

                    if (!$computerExists) {
                        Write-Host "$varLogPrefix Enabling CredSSP credentials to travel from $($env:COMPUTERNAME) to $remoteComputer"
                        Enable-WSManCredSSP -Role Client -DelegateComputer "$remoteComputer" -Force | Out-Null
                    }
                }

                # Copy the Master Data Services deployment package from the temporary directory to the build drop location.
                #
                if ($packagePath) {

                    $dropPath = Join-Path "$varDropLocation" "$packagePath"

                    New-Item -ItemType Directory -Path "$dropPath" | Out-Null

                    Write-Host "$varLogPrefix $tempPackageFile -> $dropPath"

                    Copy-Item "$tempPackageFile" "$dropPath"
                }
                else {
                    Copy-Item $"tempPackageFile" "$varDropLocation"
                }
            };
            "ErrorAction" = "Stop"
        }

        # If running remotely
        #
        if (!$curComputerName.StartsWith("localhost")) {
            $invokeArgs.Add("ComputerName", $curComputerName)
            $invokeArgs.Add("Authentication", "Credssp")

            $credSSP = Get-WSManCredSSP

            $computerExists = $false

            if ($credSSP -ne $null) {
                if ($credSSP.length -gt 0) {
                    $trustedClients = $credSSP[0].Substring($credSSP[0].IndexOf(":") + 2)
                    $trustedClientsList = $trustedClients -split "," | % { $_.Trim() }
            
                    if ($trustedClientsList.Contains("wsman/$curComputerName")) {
                        $computerExists = $true
                    }
                }
            }

            if (!$computerExists) {
                "$logPrefix Enabling CredSSP credentials to travel from $($env:COMPUTERNAME) to $curComputerName"
                Enable-WSManCredSSP -Role Client -DelegateComputer "$curComputerName" -Force | Out-Null
            }

            # Add credentials so we can handle double-hop scenarios
            #
            if ($credentialUserName) {

                $credentials = Get-BuildCredentials $credentialUserName
                $invokeArgs.Add("Credential", $credentials)
            }
        }

        Invoke-Command @invokeArgs
    }
}