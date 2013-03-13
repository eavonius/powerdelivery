function Enable-WebDeploy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $webComputer, 
        [Parameter(Mandatory=1)][string] $webDeployDir, 
        [Parameter(Mandatory=1)][string] $webSite, 
        [Parameter(Mandatory=1)][string] $webPort, 
        [Parameter(Mandatory=1)][string] $webPassword, 
        [Parameter(Mandatory=0)][string] $runtimeVersion = '4.0'
    )

    $webDeployScriptsDir = "$webDeployDir\Scripts"
    $siteSetupArgs = "-siteName $webSite -publishSettingSavePath C:\Inetpub\$webSite -publishSettingFileName $($webSite).publishsettings -sitePhysicalPath C:\Inetpub\$webSite -sitePort $webPort -siteAppPoolName $webSite -deploymentUserName $webSite -deploymentUserPassword '$($webPassword)' -managedRunTimeVersion v$runtimeVersion"
    $setupSiteResult = Invoke-Expression -Command "Invoke-Command -ComputerName $webComputer -ScriptBlock { & ""$webDeployScriptsDir\SetupSiteForPublish.ps1"" $siteSetupArgs }"
}