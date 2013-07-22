# PowerDeliveryASPNETMVC4_WithCmdlets.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline. 
#
# This sample script uses primarily cmdlets. See the script named 
# PowerDeliveryASPNETMVC4_WithModules.ps1 for a sample that uses 
# primarily delivery modules to do work instead of calling cmdlets.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4_WithCmdlets' -Version '1.0.0'

Import-DeliveryModule WebDeploy

# Initialize variables needed by your build
#
Init {

	$script:buildConfiguration 	= Get-BuildSetting BuildConfiguration
	$script:unitTestsPath 		= Get-BuildSetting UnitTestsPath
	$script:databaseServer 		= Get-BuildSetting DatabaseServer
	$script:databaseName 		= Get-BuildSetting DatabaseName
	
	$script:dbScriptsDir		= "Databases\PowerDeliveryASPNETMVC4DB"
}

# Compile source code or intermediary files and deploy outputs to the drop location (UNC path on TFS)
#
Compile {

	Invoke-MSBuild -projectFile PowerDeliveryASPNETMVC4.sln -properties @{'DeployOnBuild' = 'true'; 'PublishProfile' = 'default'}

	# Publish assets to drop location for use during deployment
	#
	Publish-BuildAssets "PowerDeliveryASPNETMVC4\DeploymentPackage\PowerDeliveryASPNETMVC4.zip" WebSites\PowerDeliveryASPNETMVC4
	Publish-BuildAssets "PowerDeliveryASPNETMVC4.Acceptance\bin\$buildConfiguration\*.*" AcceptanceTests
	Publish-BuildAssets "PowerDeliveryASPNETMVC4.Tests\bin\$buildConfiguration\*.*" UnitTests
	Publish-BuildAssets "PowerDeliveryASPNETMVC4DB" Databases -recurse
}

# Run automated unit tests
#
TestUnits {
	Invoke-MSTest -file $unitTestsPath -category Unit -results UnitTestResults.trx
}

# Make modifications to the target environment
#
SetupEnvironment {
}

# Deploy your assets to the target environment
#
Deploy {

	# Bring down scripts from drop location into current directory to run roundhouse
	#
	Get-BuildAssets Databases .
	Invoke-Roundhouse -server $databaseServer -database $databaseName -scriptsDir $dbScriptsDir
}

# Test modifications to the target environment
#
TestEnvironment {
}

# Run automated acceptance tests
#
TestAcceptance {
}

# Run longer and more intensive capacity tests
#
TestCapacity {
}