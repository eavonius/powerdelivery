function Initialize-WebDeployDeliveryModule {

	Register-DeliveryModuleHook 'PreDeploy' {
	
		function Load-WebAdministration
		{
		    $ModuleName = "WebAdministration"
		    $ModuleLoaded = $false
		    $LoadAsSnapin = $false

		    if ($PSVersionTable.PSVersion.Major -ge 2)
		    {
		        if ((Get-Module -ListAvailable | ForEach-Object {$_.Name}) -contains $ModuleName)
		        {
		            Import-Module $ModuleName

		            if ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName)
		                { $ModuleLoaded = $true } else { $LoadAsSnapin = $true }
		        }
		        elseif ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName)
		            { $ModuleLoaded = $true } else { $LoadAsSnapin = $true }
		    }
		    else
		    { $LoadAsSnapin = $true }

		    if ($LoadAsSnapin)
		    {
		        try
		        {
		            if ((Get-PSSnapin -Registered | ForEach-Object {$_.Name}) -contains $ModuleName)
		            {
		                if ((Get-PSSnapin -Name $ModuleName -ErrorAction SilentlyContinue) -eq $null) 
		                    { Add-PSSnapin $ModuleName }

		                if ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName)
		                    { $ModuleLoaded = $true }
		            }
		            elseif ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName)
		                { $ModuleLoaded = $true }
		        }

		        catch
		        {
		            Write-Error "`t`t$($MyInvocation.InvocationName): $_"
		            Exit
		        }
		    }
		}
	
		$moduleConfig = Get-BuildModuleConfig
		$webDeployments = $moduleConfig.WebDeploy

		if ($webDeployments) {
			$webDeployments.Keys | % {
				$invokeArgs = @{}
				
				$deployment = $webDeployments[$_]

				$webDeployDir = "C:\Program Files\IIS\Microsoft Web Deploy v3"
				
				if ($deployment.WebDeployDir) {
					$webDeployDir = $deployment.WebDeployDir
				}
				
				$msDeployPath = Join-Path $webDeployDir "msdeploy.exe"

				if ($deployment.WebComputer) {
					$invokeArgs.Add('webComputer', $deployment.WebComputer)
				}
				$invokeArgs.Add('webDeployDir', $webDeployDir)
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

				if ((Get-PSSnapin -Name "wdeploysnapin3.0" -ErrorAction SilentlyContinue) -eq $null) {
			   		Add-PSSnapin "wdeploysnapin3.0"
				}
				
				if ($deployment.webComputer -like 'localhost') {
					
					$deployment.webComputer = $env:COMPUTERNAME
					$deployment.webUrl = $deployment.webUrl.Replace("localhost", $env:COMPUTERNAME)
					
					Load-WebAdministration
					#Import-Module WebAdministration
					
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

				try {

					if ($deployment.BringOffline) {
						if ($deployment.BringOffline -eq 'true') {

							$deleteOfflineFile = "$msDeployPath -verb:delete -dest:contentPath=$($deployment.webSite)/App_Offline.htm,computername=$($deployment.webComputer)"
							
							$deleteOfflineFileResult = Invoke-Command -ComputerName $deployment.webComputer -ErrorAction SilentlyContinue {
								$using:deleteOfflineFile
							}
												
							$offlineCmd = "$msDeployPath -verb:sync -source:iisApp=$($deployment.webSite) -dest:auto,computername=$($deployment.webComputer) -enableRule:AppOffline -enableRule:DoNotDeleteRule"
							
							Invoke-Command -ComputerName $deployment.webComputer -ErrorAction Stop {
								$using:offlineCmd
							}
						}
					}
				
					Restore-WDPackage -Package $deployment.Package `
									-DestinationPublishSettings $publishSettingsFile `
									-Parameters $deployment.Parameters `
									-ErrorAction Stop
				}
				catch {
					"The web deployment failed. Please review the parameters you are passing and ensure that they match those expected by the parameters.xml file in your web deploy package .zip file"
					throw
				}
				
				Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "WebDeploy: $($deployment.Package) -> $($deployment.webURL) ($($deployment.webComputer))"
			}
		}
	}
}
