function Initialize-AssetsDeliveryModule {

	Register-DeliveryModuleHook 'PostCompile' {
	
		$yamlConfig = Get-BuildYamlConfig
		$assetOperations = $yamlConfig.Assets

		if ($assetOperations) {
			$assetOperations.Keys | % {
				$invokeArgs = @{}

				$assetOperation = $assetOperations[$_]
				
				if ($assetOperation.Path) {
					$invokeArgs.Add('path', $assetOperation.Path)
				}
				if ($assetOperation.Destination) {
					$invokeArgs.Add('destination', $assetOperation.Destination)
				}
				if ($assetOperation.Filter) {
					$invokeArgs.Add('filter', $assetOperation.Filter)
				}
				& Publish-BuildAssets @invokeArgs
			}
		}
	}
}