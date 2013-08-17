# %BUILD_NAME%.ps1
# 
# The script for %BUILD_NAME%'s continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline '%BUILD_NAME%' -Version '1.0.0'

# Load settings you need for the entire build
#
Init {
    $script:MSBuild 		= Get-BuildSetting MSBuild
	$script:WebDeploy 		= Get-BuildSetting WebDeploy
    $script:Roundhouse 		= Get-BuildSetting Roundhouse
	$script:UnitTests 		= Get-BuildSetting UnitTests
	$script:AcceptanceTests = Get-BuildSetting AcceptanceTests
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {

	Invoke-BuildConfigSection $MSBuild Invoke-MSBuild
}

# Run automated unit tests
#
TestUnits {

	Invoke-BuildConfigSection $UnitTests Invoke-MSTest
}

# Deploy your software assets to the target environment
#
Deploy {

    Invoke-BuildConfigSections $Roundhouse Invoke-Roundhouse
	Invoke-BuildConfigSection $WebDeploy Publish-WebDeploy
}

# Test modifications to the target environment
#
TestEnvironment {
}

# Run automated acceptance tests
#
TestAcceptance {

	Invoke-BuildConfigSection $AcceptanceTests Invoke-MSTest
}

# Run longer and more intensive capacity tests
#
TestCapacity {
}