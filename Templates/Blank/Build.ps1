# Build.ps1
# 
# PowerShell script for a continous delivery build using powerdelivery.
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
$appName = 'Your Application Name'
$appScript = 'Build'

# Load settings you need for the entire build
#
function Init() {

    $global:currentDirectory = Get-Location

    # For example
    #
    # $global:mySetting = Get-BuildSetting -name "MySetting"
    # $global:myOtherSetting = Get-BuildSetting -name "MyOtherSetting"
}


function PreCompile() {
}

# Compile any projects or solutions using MSBuild or other tools
#
function Compile() {
}

function PostCompile() {
}


function PreSetupEnvironment() {
}

# Make modifications to the target environment
#
function SetupEnvironment() {
}

function PostSetupEnvironment() {
}


function PreTestEnvironment() {
}

# Test modifications to the target environment
#
function TestEnvironment() {
}

function PostTestEnvironment() {
}


function PreDeploy() {
}


# Deploy your software assets to the target environment
#
function Deploy() {
}

function PostDeploy() {
}


function PreTestUnits() {
}

# Run automated unit tests
#
function TestUnits() {
}

function PostTestUnits() {
}


function PreTestAcceptance() {
}

# Run automated acceptance tests
#
function TestAcceptance() {
}

function PostTestAcceptance() {
}


function PreTestCapacity() {
}

# Run longer and more intensive capacity tests
#
function TestCapacity() {
}

function PostTestCapacity() {
}


.\PowerShellModules\PowerDelivery.ps1