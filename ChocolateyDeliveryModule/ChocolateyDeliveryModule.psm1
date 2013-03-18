function Initialize-ChocolateyDeliveryModule {
	Register-DeliveryModuleHook 'PreInit' {
		$chocolateyPackages = "packages.config"
		if (Test-Path $chocolateyPackages) {
			Exec -errorMessage "Error installing chocolatey packages" {
				cinst $chocolateyPackages
			}
		}
	}
}