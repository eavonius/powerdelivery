# Build.ps1
# 
# PowerShell script for a continous delivery build using powerdelivery.
#
# https://github.com/eavonius/powerdelivery

Param (
	[Switch] $onServer,
	[Parameter()]
	[ValidateNotNullOrEmpty()] 
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
    $pipelineDB
)

$env:PSModulePath += ";.\PowerShellModules"

$appVersion = '1.0.0'

function Compile() {
}

function SetupEnvironment() {
}

function TestEnvironment() {
}

function Deploy() {
}

function TestUnits() {
}

function TestAcceptance() {
}

function TestCapacity() {
}

.\PowerShellModules\ContinuousDelivery.ps1
