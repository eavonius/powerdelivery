# %BUILD_NAME%.ps1
# 
# The script for %BUILD_NAME%'s continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline '%BUILD_NAME%' -Version '1.0.0'

# Load settings you need for the entire build
#
Init {

    $script:currentDirectory = Get-Location

    # For example
    #
    # $script:mySetting = Get-BuildSetting -name "MySetting"
    # $script:myOtherSetting = Get-BuildSetting -name "MyOtherSetting"
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