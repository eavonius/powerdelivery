# Build.ps1
# 
# PowerShell script for a continous delivery ASP.NET web site using powerdelivery.
#
# https://github.com/eavonius/powerdelivery

Param (
	[Switch] $onServer,
	[Parameter()]
	$dropLocation,
	$changeSet,
	$requestedBy,
	$teamProject,
	$workspaceName,
	$environment,
    $buildUri,
    $collectionUri,
    $priorBuild
)

$env:PSModulePath += ";.\PowerShellModules"

$appVersion = '1.0.0'
$appName = '%BUILD_NAME%'
$appScript = '%BUILD_NAME%'

# Load settings you need for the entire build
#
function Init() {

    $global:currentDirectory = Get-Location

    $global:siteServerName = Get-BuildSetting -name "SiteServerName"
}

# Compile any projects or solutions using MSBuild or other tools
#
function Compile() {
    Invoke-MSBuild -buildConfiguration "$environment" -projectFile "MyWebSite/MyWebSite.sln" `
                   -properties @{"CreatePackageOnPublish" = "true"; "DeployOnBuild" = "false"}
}

# Deploy your software assets to the target environment
#
function Deploy() {
    Exec {
        msdeploy MyWebSite.deploy.cmd /p:Configuration="$environment" /m:"$siteServerName"
    }
}

.\PowerShellModules\PowerDelivery\PowerDelivery.ps1