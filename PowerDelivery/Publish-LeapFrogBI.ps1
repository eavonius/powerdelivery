<#
.Synopsis
Publishes a data mart created by LeapFrogBI.

.Description
Publishes a data mart created by LeapFrogBI.

.Parameter name
The name of the data mart. This name should be unique amongst any other LeapFrogBI 
data marts you are publishing to the same servers.

.Parameter connectionString
The connection string to the database that the LeapFrogBI data mart will be 
deployed into.

.Parameter packagesPath
The relative path to the TFS drop folder containing SSIS packages to deploy. Any SSIS 
packages directly within this path will get deployed. Any SSIS packages in a subdirectory 
of that path named after the current environment (Commit, Test, Production etc.) will 
also get deployed.

.Parameter lifecycle
Optional. The name of the target LeapFrogBI lifecycle to deploy to. A lifecycle is 
synonymous with an environment. By default this will be set to the current environment.

.Parameter environmentVariable
Optional. The environment variable that will contain the connectionString so LeapFrogBI 
can find the correct connection to use from SSIS packages. By default this will be set 
to "LFBICONSOLE" with the environment appended (e.g. "LFBICONSOLECommit").

.Parameter jobPrefix
Optional. The prefix of SQL jobs for this data mart. By default this will be set to 
"LFBI" with the environment appended and suffixed with an underscore (e.g. "LFBICommit_").

.Parameter timeoutMinutes
Optional. The number of minutes to wait for processing to complete before failing the 
build. By default this will be set to 15 minutes.

.Example
Publish-LeapFrogBI "MyDataMart" "MyDataMartPackages" "Server=myserver;Initial Catalog=mydatamart"
#>
function Publish-LeapFrogBI {
    param(
        [Parameter(Position=0,Mandatory=1)] [string] $name,
        [Parameter(Position=1,Mandatory=1)] [string] $computerName,
        [Parameter(Position=0,Mandatory=1)] [string] $packagesPath,
        [Parameter(Position=1,Mandatory=1)] [string] $connectionString,
        [Parameter(Position=2,Mandatory=0)] [string] $lifecycle = (Get-BuildEnvironment),
        [Parameter(Position=3,Mandatory=0)] [string] $environmentVariable = "LFBICONSOLE$(Get-BuildEnvironment)",
        [Parameter(Position=4,Mandatory=0)] [string] $jobPrefix = "LFBI$(Get-BuildEnvironment)_",
        [Parmaeter(Position=5,Mandatory=0)] [string] $timeoutMinutes = 15
    )

    $dropLocation = Get-BuildDropLocation

    $computerNames = $computerName -split "," | % { $_.Trim() }

    foreach ($curComputerName in $computerNames) {

        if ($BuildEnvironment -ne 'Local') {

            # Copy LeapFrogBI SSIS packages to network share on SSAS server
            #
            Deploy-BuildAssets $packagesPath "LeapFrogBI\$($name)"
            Deploy-BuildAssets "$packagesPath\$($lifecycle)" "LeapFrogBI\$($name)"
        }
        
        # Set the LeapFrogBI environment variable on database server
        #
        Set-EnvironmentVariable -ComputerName $curComputerName -Name $environmentVariable -Value $connectionString
    }

    # Restart the SQL agent service on the database server
    #
    Get-Service -ComputerName $DataMartDatabaseServer SQLSERVERAGENT | Restart-Service
    Do {
        Start-Sleep -Seconds 15
    } Until ((Get-Service -ComputerName $DataMartDatabaseServer SQLSERVERAGENT).Status -eq "Running")

    # Disable LeapFrogBI SQL jobs
    #
    Disable-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)*"

    # Run the LeapFrogBI Deployment SSIS package
    #
    Invoke-SSISPackage -Server $DataMartDatabaseServer -Package $ACCBIDeployPackage
    
    # Deploy database migrations with RoundhousE
    #
    Invoke-BuildConfigSections $Databases Invoke-Roundhouse

    # Enable LeapFrogBI SQL jobs
    #
    Enable-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)*"
    
    # Run LeapFrogBI "Reset" package to start processing
    #
    Start-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)Reset"

    # Wait for LeapFrogBI to complete processing
    #
    Wait-ForLeapFrogBI -DataMartConnectionString $DataMartConnectionString -TimeoutMinutes $LeapFrogBI.TimeoutMinutes       
}