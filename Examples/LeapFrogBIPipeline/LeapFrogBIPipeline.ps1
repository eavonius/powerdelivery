# LeapFrogBIPipeline.ps1
# 
# The script for LeapFrogBIPipeline's continous delivery pipeline.
#
# This example script does the following:
#
# 1. Compile Visual Studio projects that contain SSIS packages, 
#    a cube definition, and acceptance tests for the cube.
#
# 2. Copy all files needed to deploy to the drop folder in TFS:
#
#      * The output of the compiled Visual Studio projects in step #1
#      * LeapFrogBI packages that were downloaded from the website (and are now in source control)
#      * RoundhousE T-SQL database migration scripts
#
# 3. Create a remote network share if it doesn't exist on the target SSIS server.
#
# 4. Copy LeapFrogBI packages to the network share.
#
# 5. Set a system environment variables that help LeapFrogBI find the database to deploy to.
#
# 6. Restart the SQLAGENT service on the database server.
#
# 7. Stop LeapFrogBI's SQL jobs if it had been previously deployed.
#
# 8. Deploy the data mart with LeapFrogBI. 
#
# 9. Deploy any SQL database changes outside of LeapFrogBI with RoundhousE.
#
# 10. Tell LeapFrogBI to start processing and wait for it to complete.
#
# 11. Deploy the Analysis Services cube to the target SSAS server.
#
# 12. Tell SSAS to process the cube and wait for it to complete.
#
# 13. Run tests that check whether the correct number is returned from 
#     the cube when filtered by a variety of conditions.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'LeapFrogBIPipeline' -Version '1.0.0'

# Load settings you need for the entire build
#
Init {

    # General settings about the build
	#
    $script:CurrentDirectory = Get-Location
	$script:ComputerName 	 = $env:COMPUTERNAME
	$script:BuildEnvironment = Get-BuildEnvironment
	$script:DropLocation 	 = Get-BuildDropLocation
	
	# Configuration sections
	#
	$script:MSBuild	  							 = Get-BuildSetting MSBuild
	$script:Cubes								 = Get-BuildSetting Cubes
	$script:Databases							 = Get-BuildSetting Databases
	$script:AcceptanceTests 					 = Get-BuildSetting AcceptanceTests
	$script:AcceptanceTestsAppConfigReplacements = Get-BuildSetting AcceptanceTestsAppConfigReplacements
	
	# Database settings
	#
	$script:DataMartDatabaseServer	 = Get-BuildSetting DataMartDatabaseServer
	$script:DataMartConnectionString = Get-BuildSetting DataMartConnectionString
	
	# SSAS/SSIS deployment settings
	#
	$script:BIDeployPackage = Get-BuildSetting BIDeployPackage
	$script:BIPackagesShare = Get-BuildSetting BIPackagesShare
	
	# LeapFrog BI data mart settings
	#
	$script:LeapFrogBI = Get-BuildSetting LeapFrogBI

	# Cube settings
	#
	$script:TabularServer = Get-BuildSetting TabularServer
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {

	# Compile Visual Studio projects
	#
	Invoke-BuildConfigSections $MSBuild Invoke-MSBuild
}

# Run automated unit tests
#
TestUnits {


}

# Deploy your software assets to the target environment
#
Deploy {

	if ($BuildEnvironment -ne 'Local') {

		# Copy the cube definition to the the SSAS server
		#
		copy (Join-Path $DropLocation "Cubes\ACC_BI\*.*") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -Force

		# Deploy cubes
		#
        Invoke-BuildConfigSections $Cubes Publish-SSAS

		# Copy LeapFrogBI SSIS packages to network share on SSAS server
		#
		copy (Join-Path $DropLocation "Packages\LeapFrog\$($LeapFrogBI.Lifecycle)\*.*") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -force
		
		# Copy other SSIS packages to network share on SSAS server
		#
		copy (Join-Path $DropLocation "Packages\*.dtsx") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -force
	}
	
	# Set the LeapFrogBI environment variable on database server
	#
	Set-EnvironmentVariable -ComputerName $DataMartDatabaseServer -Name $LeapFrogBI.EnvironmentVariable -Value $DataMartConnectionString

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

# Test modifications to the target environment
#
TestEnvironment {
}

# Run automated acceptance tests
#
TestAcceptance {

	if ($BuildEnvironment -ne 'Local') {

		# Replace settings in App.config for acceptance tests 
		# to point them to the right cube (dev/test/prod)
		#
		Invoke-BuildConfigSection $AcceptanceTestAppConfigReplacements Update-XmlFile

		# Run acceptance tests against the cube
		#
		Invoke-BuildConfigSections $AcceptanceTests Invoke-MSTest
	}
}

# Run longer and more intensive capacity tests
#
TestCapacity {
}