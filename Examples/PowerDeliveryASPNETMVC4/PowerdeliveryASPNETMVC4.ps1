# PowerDeliveryASPNETMVC4.ps1
# 
# The script for PowerDeliveryASPNETMVC4's continous delivery pipeline.
#
# https://github.com/eavonius/powerdelivery

Pipeline 'PowerDeliveryASPNETMVC4' -Version '1.0.0'

Import-DeliveryModule MSBuild
Import-DeliveryModule HyperV

Init { 
	$script:currentDirectory  = Get-Location
	$script:dropLocation 	  = Get-BuildDropLocation
		
	$script:dbServer 		  = Get-BuildSetting -name DbServer
	$script:dbName   		  = Get-BuildSetting -name DbName
	$script:webPassword 	  = Get-BuildSetting -name WebPassword
	$script:webComputer 	  = Get-BuildSetting -name WebComputer
	$script:webPort     	  = Get-BuildSetting -name WebPort
	$script:webURL      	  = Get-BuildSetting -name WebURL
	$script:webSite     	  = Get-BuildSetting -name WebSite
	$script:connectionString  = Get-BuildSetting -name ConnectionString
		
	$script:webDeployPath 		   = 'PowerDeliveryASPNETMVC4\DeploymentPackage'
	$script:webDeployZipFile  	   = Join-Path $webDeployPath PowerDeliveryASPNETMVC4.zip
}

Compile { 
	Publish-BuildAssets $webDeployZipFile $webDeployPath
}

Deploy {
    $webDeployDir = "C:\Program Files\IIS\Microsoft Web Deploy v3"
    $webDeployScriptsDir = "$webDeployDir\Scripts"

	Write-BuildSummaryMessage -name "Deploy" -header "Deployments" -message "WebDeploy: $webDeployZipFile -> $webURL ($webComputer)"

	if ($webComputer -ne 'localhost') {
   		$siteSetupArgs = "-siteName $webSite -publishSettingSavePath C:\Inetpub\$webSite -publishSettingFileName $($webSite).publishsettings -sitePhysicalPath C:\Inetpub\$webSite -sitePort $webPort -siteAppPoolName $webSite -deploymentUserName $webSite -deploymentUserPassword '$($webPassword)' -managedRunTimeVersion v4.0"
   		$setupSiteResult = Invoke-Expression -Command "Invoke-Command -ComputerName $webComputer -ScriptBlock { & ""$webDeployScriptsDir\SetupSiteForPublish.ps1"" $siteSetupArgs }"

		Get-BuildAssets $webDeployZipFile $webDeployPath

	    $publishSettingsFile = "$currentDirectory\$($webSite).publishsettings"

	    Add-PSSnapin WDeploySnapin3.0

	    New-WDPublishSettings -ComputerName $webComputer -Site $webSite `
	                          -SiteUrl $webURL -FileName $publishSettingsFile `
	                          -AllowUntrusted -AgentType MSDepSvc | Out-Null

	    $deployParams = @{ `
	        "IIS Web Application Name" = $webSite; `
	        "DefaultConnection-Web.config Connection String" = $connectionString `
	    }

	    Restore-WDPackage -Package $webDeployZipFile `
	                      -DestinationPublishSettings $publishSettingsFile `
	                      -Parameters $deployParams

	}
	
    #Invoke-Roundhouse $dbServer $dbName Databases\PowerDeliveryASPNETMVCV4
}