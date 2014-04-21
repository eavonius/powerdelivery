# ProductStoreTabular.ps1
# 
# This example script does the following:
#
# 1. Compile Visual Studio projects that contain a cube definition, and acceptance tests for the cube.
#
# 2. Copy all files needed to deploy to the drop folder in TFS:
#
#      * The output of the compiled Visual Studio projects in step #1
#      * RoundhousE T-SQL database migration scripts
#
# 3. Deploy the Analysis Services cube to the target SSAS server.
#
# 4. Tell SSAS to process the cube and wait for it to complete.
#
# 5. Run tests that check whether the correct number is returned from 
#     the cube when filtered by a variety of conditions.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'ProductStoreTabular' -Version '1.0.0'

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
	$script:Assets 								 = Get-BuildSetting Assets
	$script:MSBuild	  							 = Get-BuildSetting MSBuild
	$script:Cubes								 = Get-BuildSetting Cubes
	$script:Databases							 = Get-BuildSetting Databases
	#$script:AcceptanceTests 					 = Get-BuildSetting AcceptanceTests
	#$script:AcceptanceTestsAppConfigReplacements = Get-BuildSetting AcceptanceTestsAppConfigReplacements
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {

	# Compile Visual Studio projects
	#
	Invoke-BuildConfigSection $MSBuild Invoke-MSBuild
}

# Run automated unit tests
#
TestUnits {


}

# Deploy your software assets to the target environment
#
Deploy {

	# Deploy database migrations with RoundhousE
	#
	Invoke-BuildConfigSections $Databases Invoke-Roundhouse

	if ($BuildEnvironment -ne 'Local') {

		# Copy the cube definition to the the SSAS server
		#
		#copy (Join-Path $DropLocation "Cubes\ACC_BI\*.*") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -Force

		# Deploy cubes
		#
        #Invoke-BuildConfigSections $Cubes Publish-SSAS

		# Copy LeapFrogBI SSIS packages to network share on SSAS server
		#
		#copy (Join-Path $DropLocation "Packages\LeapFrog\$($LeapFrogBI.Lifecycle)\*.*") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -force
		
		# Copy other SSIS packages to network share on SSAS server
		#
		#copy (Join-Path $DropLocation "Packages\*.dtsx") "\\$DataMartDatabaseServer\$ACCBIPackagesShare" -force

		Invoke-BuildConfigSections $Cubes Publish-SSAS
	}
	
	# Set the LeapFrogBI environment variable on database server
	#
	#Set-EnvironmentVariable -ComputerName $DataMartDatabaseServer -Name $LeapFrogBI.EnvironmentVariable -Value $DataMartConnectionString

	# Restart the SQL agent service on the database server
	#
	#Get-Service -ComputerName $DataMartDatabaseServer SQLSERVERAGENT | Restart-Service
	#Do {
#		Start-Sleep -Seconds 15
	#} Until ((Get-Service -ComputerName $DataMartDatabaseServer SQLSERVERAGENT).Status -eq "Running")

	# Disable LeapFrogBI SQL jobs
	#
	#Disable-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)*"

	# Run the LeapFrogBI Deployment SSIS package
	#
	#Invoke-SSISPackage -Server $DataMartDatabaseServer -Package $ACCBIDeployPackage

	# Enable LeapFrogBI SQL jobs
	#
	#Enable-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)*"
	
	# Run LeapFrogBI "Reset" package to start processing
	#
	#Start-SqlJobs -ServerName $DataMartDatabaseServer -Jobs "$($LeapFrogBI.JobPrefix)Reset"

	# Wait for LeapFrogBI to complete processing
	#
	#Wait-ForLeapFrogBI -DataMartConnectionString $DataMartConnectionString -TimeoutMinutes $LeapFrogBI.TimeoutMinutes		
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
		#Invoke-BuildConfigSection $AcceptanceTestAppConfigReplacements Update-XmlFile

		# Run acceptance tests against the cube
		#
		#Invoke-BuildConfigSections $AcceptanceTests Invoke-MSTest
	}
}

# Run longer and more intensive capacity tests
#
TestCapacity {
}