function RegisterMSTestHook {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)] $testSectionName
	)

	$moduleConfig = Get-BuildModuleConfig
	$msTestSection = $moduleConfig.MSTest
	
	if ($msTestSection) {
		$testSection = $msTestSection[$testSectionName]
		if ($testSection) {
			$testSection.Keys | % {
				$invokeArgs = @{}
				
				$testProject = $testSection[$_]
				
				if ($testProject.File) {
					$invokeArgs.Add('file', $testProject.File)
				}
				if ($testProject.Results) {
					$invokeArgs.Add('results', $testProject.Results)
				}
				if ($testProject.Category) {
					$invokeArgs.Add('category', $testProject.Category)
				}
				if ($testProject.Platform) {
					$invokeArgs.Add('platform', $testProject.Platform)
				}
				if ($testProject.BuildConfiguration) {
					$invokeArgs.Add('buildConfiguration', $testProject.BuildConfiguration)
				}
				& Invoke-MSTest @invokeArgs
			}
		}
	}
}

function Initialize-MSTestDeliveryModule {

	Register-DeliveryModuleHook 'PreTestUnits' {
		RegisterMSTestHook 'UnitTests'
	}
	
	Register-DeliveryModuleHook 'PreTestAcceptance' {
		RegisterMSTestHook 'AcceptanceTests'
	}
}