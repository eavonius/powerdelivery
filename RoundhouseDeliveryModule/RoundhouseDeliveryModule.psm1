function Initialize-RoundhouseDeliveryModule {

	Register-DeliveryModuleHook 'PostDeploy' {
	
		$moduleConfig = Get-BuildModuleConfig
		$roundhouseDatabases = $moduleConfig.Roundhouse

		if ($roundhouseDatabases) {
			$roundhouseDatabases.Keys | % {
				$invokeArgs = @{}
				
				$rhDatabase = $roundhouseDatabases[$_]
				
				if ($rhDatabase.Server) {
					$invokeArgs.Add('server', $rhDatabase.Server)
				}
				if ($rhDatabase.Database) {
					$invokeArgs.Add('database', $rhDatabase.Database)
				}
				if ($rhDatabase.ScriptsDir) {
					$invokeArgs.Add('scriptsDir', $rhDatabase.ScriptsDir)
				}
				if ($rhDatabase.RestorePath) {
					$invokeArgs.Add('restorePath', $rhDatabase.RestorePath)
				}
				if ($rhDatabase.RestoreOptions) {
					$invokeArgs.Add('restoreOptions', $rhDatabase.RestoreOptions)
				}
				& Invoke-Roundhouse @invokeArgs
			}
		}
	}
}