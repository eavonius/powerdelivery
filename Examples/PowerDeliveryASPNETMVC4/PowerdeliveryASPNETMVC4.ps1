# PowerDeliveryASPNETMVC4.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4' -Version '1.0.0'

Import-DeliveryModule Chocolatey
Import-DeliveryModule MSBuild
Import-DeliveryModule Roundhouse
Import-DeliveryModule WebDeploy

Init { 
	$script:webDeployPath 	 = "PowerDeliveryASPNETMVC4\DeploymentPackage"
	$script:webDeployZipFile = Join-Path $webDeployPath PowerDeliveryASPNETMVC4.zip
}

Compile { 
	Publish-BuildAssets $webDeployZipFile $webDeployPath
}

Deploy {
	Get-BuildAssets $webDeployZipFile $webDeployPath
}