# LeapFrogBIPipeline.ps1
# 
# The script for LeapFrogBIPipeline's continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'LeapFrogBIPipeline' -Version '1.0.0'

# Load settings you need for the entire build
#
Init {

    # General settings about the build
	#
    $script:currentDirectory 	= Get-Location
	$script:computerName 	 	= $env:COMPUTERNAME
	$script:buildEnvironment 	= Get-BuildEnvironment
	$script:dropLocation 	 	= Get-BuildDropLocation
	
	$script:TabularServer		= Get-BuildSetting TabularServer
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {

	Invoke-BuildConfigSection Solution Invoke-MSBuild
}

# Run automated unit tests
#
TestUnits {
}

# Deploy your software assets to the target environment
#
Deploy {

	if ($buildEnvironment -ne 'Local') {
	
		New-RemoteShare $tabularServer DataMartPackages D:\DataMartPackages
	
		$packagesDeployPath = "\\$tabularServer\DataMartPackages\$buildEnvironment"
	
		Copy-FilesWithLongPath Cubes\MSDFGlobal $packagesDeployPath
		Copy-FilesWithLongPath Cubes\MSDFGlobal_Source $packagesDeployPath
	}
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
