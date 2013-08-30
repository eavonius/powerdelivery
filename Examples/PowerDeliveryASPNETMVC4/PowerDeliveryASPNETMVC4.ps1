# PowerDeliveryASPNETMVC4.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline. 
#
# This example deployment pipeline promotes an ASP.NET MVC4 web site 
# and a database through deployment environments.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4' -Version '1.0.0'

# Load settings you need for the entire build
#
Init {
    $script:Roundhouse 		= Get-BuildSetting Roundhouse
	$script:MSBuild 		= Get-BuildSetting MSBuild
	$script:UnitTests 		= Get-BuildSetting UnitTests
	$script:AcceptanceTests = Get-BuildSetting AcceptanceTests
	$script:WebDeploy 		= Get-BuildSetting WebDeploy
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {

	Invoke-BuildConfigSections $MSBuild Invoke-MSBuild
}

# Run automated unit tests
#
TestUnits {

	Invoke-BuildConfigSections $UnitTests Invoke-MSTest 
}

# Deploy your software assets to the target environment
#
Deploy {

    Invoke-BuildConfigSections $Roundhouse Invoke-Roundhouse
	Invoke-BuildConfigSections $WebDeploy Publish-WebDeploy
}

# Test modifications to the target environment
#
TestEnvironment {
}

# Run automated acceptance tests
#
TestAcceptance {

	Invoke-BuildConfigSections $AcceptanceTests Invoke-MSTest
}

# Run longer and more intensive capacity tests
#
TestCapacity {
}