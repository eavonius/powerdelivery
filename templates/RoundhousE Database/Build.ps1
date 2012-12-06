# Build.ps1
# 
# PowerShell script for a continous delivery RoundHouse database using powerdelivery.
#
# https://github.com/eavonius/powerdelivery

Param (
	[Switch] $onServer,
	[Parameter()]
	[String]
	$dropLocation,
	[Parameter()]
	[String]
	$changeSet,
	[Parameter()]
	[String]
	$requestedBy,
	[Parameter()]
	[String]
	$teamProject,
	[Parameter()]
	[String]
	$workspaceName,
	[String]
	$environment,
    [String]
    $buildUri,
    [String]
    $collectionUri
)

$env:PSModulePath += ";.\PowerShellModules"

$appVersion = '1.0.0'
$appName = '%BUILD_NAME%'
$appScript = '%BUILD_NAME%'

# Load settings you need for the entire build
#
function Init() {

    $global:currentDirectory = Get-Location

    $global:siteServerName = Get-BuildSetting -name "DBServerName"
    $global:databaseName = Get-BuildSetting -name "DatabaseName"
}

# Compile any projects or solutions using MSBuild or other tools
#
function Compile() {

    # Copy your database scripts to the drop folder
    Copy-Item -Path "Databases\MyDatabase" -Destination $dropLocation
}

# Deploy your software assets to the target environment
#
function Deploy() {
    if ($environment -eq "Local" -or $environment -eq "Commit") {
        Remove-Roundhouse -server $dbServerName -database $databaseName
    }
    
    Publish-Roundhouse -server $dbServerName -database $databaseName
}

.\PowerShellModules\PowerDelivery.ps1