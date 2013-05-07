function Initialize-WebDeployDeliveryModule {

	Register-DeliveryModuleHook 'PreDeploy' {
	
		$yamlConfig = Get-BuildYamlConfig
		$webDeployments = $yamlConfig.WebDeploy

		if ($webDeployments) {
			$webDeployments.Keys | % {
				$invokeArgs = @{}
				
				$deployment = $webDeployments[$_]

				if ($deployment.WebComputer) {
					$invokeArgs.Add('webComputer', $deployment.WebComputer)
				}
				if ($deployment.WebDeployDir) {
					$invokeArgs.Add('webDeployDir', $deployment.WebDeployDir)
				}
				else {
					$invokeArgs.Add('webDeployDir', "C:\Program Files\IIS\Microsoft Web Deploy v3")
				}
				if ($deployment.WebPort) {
					$invokeArgs.Add('webPort', $deployment.WebPort)
				}
				if ($deployment.WebSite) {
					$invokeArgs.Add('webSite', $deployment.WebSite)
				}
				if ($deployment.WebPassword) {
					$invokeArgs.Add('webPassword', $deployment.WebPassword)
				}

				& Enable-WebDeploy @invokeArgs
				
			    $publishSettingsFile = "$(gl)\$($deployment.webSite).publishsettings"

			   	Add-PSSnapin wdeploysnapin3.0
				
				if ($deployment.webComputer -like 'localhost') {
					
					$deployment.webComputer = $env:COMPUTERNAME
					$deployment.webUrl = $deployment.webUrl.Replace("localhost", $env:COMPUTERNAME)
					
					Import-Module WebAdministration
					
					if (!(Test-Path "IIS:\AppPools\$($deployment.webSite)"))
  					{
						$appPoolObj = New-WebAppPool -Name $deployment.webSite -Force
					}
					
					$webSiteObj = Get-Website -Name $deployment.webSite
					if (!$webSiteObj) {
						"Creating $($deployment.webSite) on $($deployment.webComputer)..."
						$sitePath = "C:\inetpub\$($deployment.webSite)"
						mkdir $sitePath -Force | Out-Null
						$webSiteObj = New-Website -Name $deployment.webSite -ApplicationPool $deployment.webSite -Force -PhysicalPath $sitePath -Port $deployment.webPort
					}
					
					if ($deployment.Parameters -ne $null) {
						foreach ($deploymentParamKey in $($deployment.Parameters.Keys)) {
							$deploymentParamVal = $deployment.Parameters[$deploymentParamKey]
							if ($deploymentParamVal -like 'localhost') {
								$deployment.Parameters[$deploymentParamKey] = $env:COMPUTERNAME
							}
						}
					}
				}

			    New-WDPublishSettings -ComputerName $deployment.webComputer -Site $deployment.webSite `
			                          -SiteUrl $deployment.webURL -FileName $publishSettingsFile `
			                          -AllowUntrusted -AgentType MSDepSvc | Out-Null

			    Restore-WDPackage -Package $deployment.Package `
								  -DestinationPublishSettings $publishSettingsFile `
								  -Parameters $deployment.Parameters
				
				Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "WebDeploy: $($deployment.Package) -> $($deployment.webURL) ($($deployment.webComputer))"
			}
		}
	}
}