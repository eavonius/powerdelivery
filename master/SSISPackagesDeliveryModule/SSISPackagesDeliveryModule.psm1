function Initialize-SSISPackagesDeliveryModule {

	Register-DeliveryModuleHook 'PostDeploy' {
	
		$moduleConfig = Get-BuildModuleConfig
		$ssisPackages = $moduleConfig.SSISPackages

		if ($ssisPackages) {
			$ssisPackages.Keys | % {
				$invokeArgs = @{}
				
				$package = $ssisPackages[$_]
				
				if ($package.Package) {
					$invokeArgs.Add('package', $package.Package)
				}
				if ($package.Server) {
					$invokeArgs.Add('server', $package.Server)
				}
				if ($package.DTExecPath) {
					$invokeArgs.Add('dtExecPath', $package.DTExecPath)
				}
				if ($package.PackageArgs) {
					$invokeArgs.Add('packageArgs', $package.PackageArgs)
				}
				& Invoke-SSIS @invokeArgs
			}
		}
	}
}