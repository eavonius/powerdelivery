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

function Publish-WebDeploy {
	param(
		[Parameter(Position=0,Mandatory=1)] $WebComputer,
		[Parameter(Position=1,Mandatory=1)] [string] $Package,
		[Parameter(Position=2,Mandatory=1)] [string] $WebSite,
		[Parameter(Position=3,Mandatory=1)] [int] $WebPort,
		[Parameter(Position=4,Mandatory=1)] [string] $WebURL,
		[Parameter(Position=5,Mandatory=1)] [string] $WebPassword,
		[Parameter(Position=6,Mandatory=0)] [Hashtable] $Parameters,
		[Parameter(Position=7,Mandatory=0)] [string] $BringOffline = 'false',
		[Parameter(Position=8,Mandatory=0)] [string] $WebDeployDir = "C:\Program Files\IIS\Microsoft Web Deploy v3",
        [Parameter(Position=9,Mandatory=0)] $RuntimeVersion = 'v4.0'
	)

    $logPrefix = "Publish-WebDeploy:"

    $computerNames = $WebComputer -split "," | % { $_.Trim() }
	
	foreach ($computerName in $computerNames) {
	
		$msDeployPath = Join-Path $WebDeployDir "msdeploy.exe"

		$invokeArgs = @{}
		
		$invokeArgs.Add('webComputer', $computerName)
		$invokeArgs.Add('webDeployDir', $WebDeployDir)
		$invokeArgs.Add('WebPort', $WebPort)
		$invokeArgs.Add('webSite', $WebSite)
		$invokeArgs.Add('webPassword', $WebPassword)
        $invokeArgs.Add('runtimeVersion', $RuntimeVersion)

		& Enable-WebDeploy @invokeArgs
		
	    $publishSettingsFile = "$(gl)\$($WebSite).publishsettings"

		if ((Get-PSSnapin -Name "wdeploysnapin3.0" -ErrorAction SilentlyContinue) -eq $null) {
	   		Add-PSSnapin "wdeploysnapin3.0"
		}
		
		if ($computerName -like 'localhost') {
			
			$computerName = $env:COMPUTERNAME
			$WebUrl = $WebUrl.Replace("localhost", $env:COMPUTERNAME)
			
			Load-WebAdministration
			
			if (!(Test-Path "IIS:\AppPools\$($WebSite)"))
			{
				$appPoolObj = New-WebAppPool -Name $WebSite -Force
			}
			
			$webSiteObj = Get-Website -Name $WebSite
			if (!$webSiteObj) {
				"Creating $($WebSite) on $($computerName)..."
				$sitePath = "C:\inetpub\$($WebSite)"
				mkdir $sitePath -Force | Out-Null
				$webSiteObj = New-Website -Name $WebSite -ApplicationPool $WebSite -Force -PhysicalPath $sitePath -Port $WebPort
			}
			
			if ($Parameters -ne $null) {
				foreach ($deploymentParamKey in $Parameters.Keys) {
					$deploymentParamVal = $Parameters[$deploymentParamKey]
					if ($deploymentParamVal -like 'localhost') {
						$Parameters[$deploymentParamKey] = $env:COMPUTERNAME
					}
				}
			}
		}

	    New-WDPublishSettings -ComputerName $computerName -Site $WebSite `
	                          -SiteUrl $WebURL -FileName $publishSettingsFile `
	                          -AllowUntrusted -AgentType MSDepSvc | Out-Null

		try {

			if ($BringOffline) {
				if ($BringOffline -eq 'true') {

					$deleteOfflineFile = "$msDeployPath -verb:delete -dest:`"contentPath=$($WebSite)/App_Offline.htm,computername=$($computerName)`""
					
					$deleteOfflineFileResult = Invoke-Command -ComputerName $computerName -ErrorAction SilentlyContinue {
                        "$using:logPrefix $using:offlineCmd"
						iex $using:deleteOfflineFile
					}
										
					$offlineCmd = "$msDeployPath -verb:sync -source:iisApp=`"$($WebSite)`" -dest:`"auto,computername=$($computerName)`" -enableRule:AppOffline -enableRule:DoNotDeleteRule"
					
					Invoke-Command -ComputerName $computerName -ErrorAction Stop {
                        "$using:logPrefix $using:offlineCmd"
						iex $using:offlineCmd
					}
				}
			}
		
			Restore-WDPackage -Package $Package `
							-DestinationPublishSettings $publishSettingsFile `
							-Parameters $Parameters `
							-ErrorAction Stop
		}
		catch {
			"The web deployment failed. Please review the parameters you are passing and ensure that they match those expected by the parameters.xml file in your web deploy package .zip file."
			throw
		}
		
		Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "WebDeploy: $Package -> $WebURL ($computerName)"
	}
}