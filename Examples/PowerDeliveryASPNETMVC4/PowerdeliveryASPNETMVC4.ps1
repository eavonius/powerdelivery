# PowerDeliveryASPNETMVC4.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4' -Version '1.0.0'

Import-DeliveryModule MSBuild
Import-DeliveryModule Roundhouse
Import-DeliveryModule WebDeploy

Init { 
	#$script:webDeployPath 	 = "PowerDeliveryASPNETMVC4\DeploymentPackage"
	#$script:webDeployZipFile = Join-Path $webDeployPath PowerDeliveryASPNETMVC4.zip
}

Deploy {
	#Get-BuildAssets $webDeployZipFile $webDeployPath
}

TestUnits {
	#Get-BuildAssets UnitTests\*.* UnitTests
	Invoke-MSTest UnitTests\PowerDeliveryASPNETMVC4.Tests.dll UnitTestResults.trx Unit
}