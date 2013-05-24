function Initialize-RemoteSharesDeliveryModule {

	Register-DeliveryModuleHook 'PreSetupEnvironment' {
	
		$yamlConfig = Get-BuildYamlConfig
		$remoteShares = $yamlConfig.RemoteShares

		if ($remoteShares) {
			$remoteShares.Keys | % {
				$invokeArgs = @{}
				
				$remoteShare = $remoteShares[$_]
				
				if ($remoteShare.ComputerName) {
					$invokeArgs.Add('computerName', $remoteShare.ComputerName)
				}
                if ($remoteShare.ShareName) {
					$invokeArgs.Add('shareName', $remoteShare.ShareName)
				}
                if ($remoteShare.ShareDirectory) {
					$invokeArgs.Add('shareDirectory', $remoteShare.ShareDirectory)
				}
                if ($remoteShare.BuildAccountName) {
					$invokeArgs.Add('buildAccountName', $remoteShare.BuildAccountName)
				}
				& New-RemoteShare @invokeArgs
			}
		}
	}
}