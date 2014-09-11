function Backup-MasterDataServices {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $model,
        [Parameter(Position=2,Mandatory=1)][string] $service,
        [Parameter(Position=3,Mandatory=1)][string] $package,
        [Parameter(Position=4,Mandatory=0)][string] $version = "VERSION_1",
        [Parameter(Position=5,Mandatory=0)][switch] $includeData = $false,
        [Parameter(Position=6,Mandatory=0)][string] $credentialUserName,
        [Parameter(Position=7,Mandatory=0)][string] $mdsDeployPath = "C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\"
    )
    
    $logPrefix = "Backup-MasterDataServices:"

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        "$logPrefix Backing up Master Data Services model $model on $computerName"

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
            "ArgumentList" = @($model, $service, $package, $version, $includeData, $mdsDeployPath, $dropLocation, $logPrefix);
            "ScriptBlock" = {
                param($varModel, $varService, $varPackage, $varVersion, $varIncludeData, $varMdsDeployPath, $varDropLocation, $varLogPrefix)

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
                $mdsDeployPath = Join-Path $varMdsDeployPath "MDSModelDeploy"

                $mdsDeployCommand = """$mdsDeployPath"" createpackage -package ""$tempPackageFile"" -model ""$varModel"" -service ""$varService"""

                if ($varIncludeData) {
                    $mdsDeployCommand += " -version ""$varVersion"" -includedata"
                }

                Write-Host "$varLogPrefix $mdsDeployCommand"
                Invoke-Expression "& $mdsDeployCommand"

                # Copy the Master Data Services deployment package from the temporary directory to the build drop location.
                #
                if (Test-Path $tempPackageFile) {
                    $destPackagePath = $varDropLocation
                    if ($packagePath) {
                        $dropPath = Join-Path "$varDropLocation" "$packagePath"
                        if (!(Test-Path -Path "$dropPath")) {
                            New-Item -ItemType Directory -Path "$dropPath" | Out-Null
                        }
                        $destPackagePath = $dropPath
                    }
                    Write-Host "$varLogPrefix $tempPackageFile -> $destPackagePath"
                    Copy-Item "$tempPackageFile" "$destPackagePath"
                }

                if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
                    throw "Error backing up Master Data Services, exit code was $LASTEXITCODE"
                }
            };
            "ErrorAction" = "Stop"
        }

        Add-CommandCredSSP $curComputerName $invokeArgs $credentialUserName

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Backup" -header "Backups" -message "Master Data Services: $computerName -> $package"
    }
}