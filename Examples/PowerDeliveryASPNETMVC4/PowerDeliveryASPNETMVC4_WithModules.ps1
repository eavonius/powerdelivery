# PowerDeliveryASPNETMVC4_WithModules.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline. 
#
# This sample script uses delivery modules to do work instead of calling 
# cmdlets. See PoweDeliveryASPNETMVC4_WithCmdlets for a sample that uses 
# primarily cmdlets instead.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4_WithModules' -Version '1.0.0'

Import-DeliveryModule MSBuild
Import-DeliveryModule MSTest
Import-DeliveryModule WebDeploy

# Load settings you need for the entire build
#
Init {
    $script:Roundhouse = Get-BuildSetting Roundhouse
}

# Compile any projects or solutions using MSBuild or other tools
#
Compile {
}

# Run automated unit tests
#
TestUnits {
}

# Make modifications to the target environment
#
SetupEnvironment {
}

# Deploy your software assets to the target environment
#
Deploy {

    Get-BuildAssets Databases .
    Invoke-ConfigSection $Roundhouse "Invoke-Roundhouse"
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