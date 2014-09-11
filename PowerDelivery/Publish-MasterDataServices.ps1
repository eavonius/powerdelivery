function Publish-MasterDataServices {
    param(
        [Parameter(Position=0,Mandatory=1)][string] $computerName,
        [Parameter(Position=1,Mandatory=1)][string] $package,
        [Parameter(Position=2,Mandatory=1)][string] $connectionString,
        [Parameter(Position=3,Mandatory=0)][string] $version,
        [Parameter(Position=4,Mandatory=0)][string] $credentialUserName,
        [Parameter(Position=5,Mandatory=0)][string] $mdsDeployPath = "C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\"
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
            "ArgumentList" = @($package, $version, $connectionString, $mdsDeployPath, $dropLocation, $logPrefix);
            "ScriptBlock" = {
                param($varPackage, $varVersion, $varConnectionString, $varMdsDeployPath, $varDropLocation, $varLogPrefix)

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

                if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
                    throw "Error publishing Master Data Services, exit code was $LASTEXITCODE"
                }

                # Update MDS to validate any new data
                #
                $sqlConnection = New-Object System.Data.OleDb.OleDbConnection
                $sqlConnection.ConnectionString = $varConnectionString
                $sqlConnection.Open()

                $currentUserName = whoami
                
                $validateNewDataQuery = @"
DECLARE @UserId int
DECLARE @ModelId int
DECLARE @VersionId int
DECLARE @ModelName nvarchar(50)
DECLARE @ModelNames TABLE(RowID INT NOT NULL IDENTITY(1,1) primary key, ModelName nvarchar(50))
DECLARE @LastRowID int
DECLARE @RowID int

SELECT @UserId = ID FROM mdm.tblUser WHERE UserName = '$currentUserName'

INSERT INTO @ModelNames
SELECT Name FROM mdm.tblModel WHERE Name <> 'Metadata'
SELECT @RowID = MIN(RowID) FROM @ModelNames
SELECT @LastRowID = MAX(RowID) FROM @ModelNames

WHILE @RowID <= @LastRowID
BEGIN
    SELECT @ModelName = ModelName FROM @ModelNames WHERE RowID = @RowID
    SET @ModelId = (SELECT TOP 1 Model_ID FROM mdm.viw_SYSTEM_SCHEMA_MODELS WHERE Model_Name = @ModelName)
    SET @VersionId = (SELECT MAX(ID) FROM mdm.viw_SYSTEM_SCHEMA_VERSION WHERE Model_ID = @ModelId)
    EXEC mdm.udpValidateModel @UserId, @ModelId, @VersionId, 1
    SET @RowID = @RowID + 1
END
"@
                $validateNewDataCmd = New-Object System.Data.OleDb.OleDbCommand($validateNewDataQuery, $sqlConnection)
                $validateNewDataCmd.ExecuteNonQuery()
                
                $sqlConnection.Close()
            };
            "ErrorAction" = "Stop"
        }

        Add-CommandCredSSP $curComputerName $invokeArgs $credentialUserName

        Invoke-Command @invokeArgs

        Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "Master Data Services: $package -> $computerName"
    }
}