Import-Module PowerDelivery -Force

if (!$dropLocation.EndsWith('\')) {
	$dropLocation = "$($dropLocation)\"
}

$global:pdlvry_assemblyInfoFiles = @()
$global:pdlvry_currentLocation = gl
$global:pdlvry_noReleases = $true
$global:pdlvry_envConfig = @()
$global:pdlvry_buildSet = @()
$global:pdlvry_environment = $environment
$global:pdlvry_dropLocation = $dropLocation
$global:pdlvry_changeSet = $changeSet
$global:pdlvry_requestedBy = $requestedBy
$global:pdlvry_teamProject = $teamProject
$global:pdlvry_workspaceName = $workspaceName
$global:pdlvry_appName = $appName
$global:pdlvry_collectionUri = $collectionUri
$global:pdlvry_buildUri = $buildUri
$global:pdlvry_onServer = $onServer

function Require-NonNullField($variable, $errorMsg) {
	if ($variable -eq $null -or $variable -eq '') {
		throw $errorMsg;
	}
}

Write-ConsoleSpacer
Write-Host "powerdelivery - https://github.com/eavonius/powerdelivery"

if ($environment -eq $null -or $environment -eq '') {
	$environment = "Local"
}

$buildConfig = "Debug"

function InvokePowerDeliveryBuildAction($condition, $methodName, $description, $status) {
    if (Get-Command $methodName -ErrorAction SilentlyContinue and $condition) {
        Write-ConsoleSpacer
		Write-Host "$status..."
        Write-ConsoleSpacer
        Invoke-Expression $methodName
		Set-Location $global:pdlvry_currentLocation
	}
	else {
		Write-Host "No $methodName() function found in script, skipping $description phase..."
	}
}

try {
    Require-NonNullField -variable $appName -errorMsg "appName variable is required"
    Require-NonNullField -variable $appVersion -errorMsg "appVersion variable is required"
    Require-NonNullField -variable $appScript -errorMsg "appScript variable is required"

	if ($onServer -eq $true) {

		Require-NonNullField -variable $changeSet -errorMsg "-changeSet parameter is required when running on TFS"
		Require-NonNullField -variable $requestedBy -errorMsg "-requestedBy parameter is required when running on TFS"
		Require-NonNullField -variable $teamProject -errorMsg "-teamProject parameter is required when running on TFS"
		Require-NonNullField -variable $workspaceName -errorMsg "-workspaceName parameter is required when running on TFS"
		Require-NonNullField -variable $environment -errorMsg "-environment parameter is required when running on TFS"
        Require-NonNullField -variable $collectionUri -errorMsg "-collectionUri parameter is required when running on TFS"
        Require-NonNullField -variable $buildUri -errorMsg "-buildUri parameter is required when running on TFS"
        Require-NonNullField -variable $dropLocation -errorMsg "-dropLocation parameter is required when running on TFS"
		
		$buildConfig = "Release"
	}
	else {
		$requestedBy = whoami
	}
	
	$buildAppVersion = "$appVersion"
	
	if ($environment -ne 'local') {
		$changeSetNumber = $changeSet.Substring(1)
		$buildAppVersion = "$appVersion.$changeSetNumber"
	}

    $global:pdlvry_buildAppVersion = $buildAppVersion

	Write-ConsoleSpacer

    $envMessage += "App Name: $appName`r`n"
    $envMessage += "App Version: $buildAppVersion`r`n"
	
    $envMessage += "Requested By: $requestedBy`r`n"
    $envMessage += "Environment: $environment`r`n"
    $envMessage += "Running on TFS Build: $onServer`r`n"
	
	if ($onServer) {
        $envMessage += "Drop Location: $dropLocation`r`n"
        $envMessage += "TFS Team Project: $teamProject`r`n"
        $envMessage += "TFS Change Set: $changeSet`r`n"
        $envMessage += "TFS Workspace: $workspaceName`r`n"
	}

    $vsInstallDir = Get-ItemProperty -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\10.0_Config -Name InstallDir
    if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
        throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
    }
    else {
        $ENV:Path += ";$($vsInstallDir.InstallDir)"
    }

	#$ENV:Path += ";C:\Windows\Microsoft.NET\Framework\v4.0.30319"

    if (Test-Path -Path "PowerDeliveryEnvironment.csv") {
		$global:pdlvry_buildSettings = Import-Csv "PowerDeliveryEnvironment.csv"	
	}
	else {
		throw "Build configuration file PowerDeliveryEnvironment.csv not found."
	}

	$envConfigFileName = $appScript + $environment + "Environment.csv"

	if (Test-Path -Path $envConfigFileName) {
		$global:pdlvry_envConfig = Import-Csv $envConfigFileName	
	}
	else {
		throw "Build configuration file $envConfigFileName not found."
	}

	ForEach ($envVar in $global:pdlvry_envConfig) {
        $envMessage += "$($envVar.Name): $($envVar.Value)`r`n"
	}

    Write-Host $envMessage

    if ($onServer) {
        Write-BuildSummaryMessage -name "build_environment" -header "Build Environment" -message $envMessage
    }

	$releases = @()

    mkdir (Join-Path -Path $global:pdlvry_currentLocation -ChildPath 'PowerDeliveryBuildOutput') -Force | Out-Null

    InvokePowerDeliveryBuildAction -condition $true -methodName "Init" -description "initialization" -status "Initializing"
    
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreCompile" -description "pre-compilation" -status "Pre-Compiling"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "Compile" -description "compilation" -status "Compiling"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostCompile" -description "post-compilation" -status "Post-Compiling"
    
    InvokePowerDeliveryBuildAction -condition $true -methodName "PreSetupEnvironment" -description "pre-setup environment" -status "Pre-Setting Up Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "SetupEnvironment" -description "setup environment" -status "Setting Up Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostSetupEnvironment" -description "post-setup environment" -status "Post-Setting Up Environment"
    
    InvokePowerDeliveryBuildAction -condition $true -methodName "PreTestEnvironment" -description "pre-test environment" -status "Pre-Testing Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "TestEnvironment" -description "test environment" -status "Testing Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostTestEnvironment" -description "post-test environment" -status "Post-Testing Environment"
    
    InvokePowerDeliveryBuildAction -condition $true -methodName "PreDeploy" -description "pre-deploy" -status "Pre-Deploying"
    InvokePowerDeliveryBuildAction -condition $true -methodName "Deploy" -description "deploy" -status "Deploying"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostDeploy" -description "post-deploy" -status "Post-Deploying Environment"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreTestUnits" -description "pre-unit testing" -status "Pre-Testing Units"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "TestUnits" -description "unit testing" -status "Testing Units"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostTestUnits" -description "post-unit testing" -status "Post-Testing Units"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreTestAcceptance" -description "pre-acceptance testing" -status "Pre-Testing Acceptance"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "TestAcceptance" -description "acceptance testing" -status "Testing Acceptance"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostTestAcceptance" -description "post-acceptance testing" -status "Post-Testing Acceptance"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "PreTestCapacity" -description "pre-capacity testing" -status "Pre-Testing Capacity"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "TestCapacity" -description "capacity testing" -status "Testing Capacity"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "PostTestCapacity" -description "post-capacity testing" -status "Post-Testing Capacity"

	if ($onServer) {
		if ($environment -ne 'Local') {
			
            $insertRelease = "INSERT INTO dbo.Releases (IsCapacityTested, TeamProject, DropLocation, Environment, IsUserAccepted, ChangeSet, RequestedBy, AppName, AppVersion) " + `
                "VALUES(0, '$teamProject', '$dropLocation', '$environment', 0, '$changeSet', '$requestedBy', '$appName', '$buildAppVersion')"

            $buildServer = Get-BuildEnvironmentSetting -name 'BuildServer'
            $buildDatabase = Get-BuildEnvironmentSetting -name 'BuildDatabase'

            Exec -errorMessage "Unable to insert release into build database" {
                sqlcmd -E -S "$buildServer" -d "$buildDatabase" -q "$insertRelease"
            }
		}
		if ($global:pdlvry_assemblyInfoFiles.length > 0) {
			Exec -errorMessage "Unable to checkin changes to AssemblyInfo.cs versions" { 
				tf checkin /force /noprompt /author:"$requestedBy" /comment:"Updated AssemblyInfo.cs version information." | Out-Null
			}
		}
	}

	Write-Host "Build succeeded!" -ForegroundColor DarkGreen
}
Catch [System.Exception] {
	Set-Location $global:pdlvry_currentLocation
	ForEach ($assemblyInfoFile in $global:pdlvry_assemblyInfoFiles) {
		Exec -errorMessage "Unable to undo checkout of $assemblyInfoFile" { 
			tf undo $assemblyInfoFile | Out-Null
		}
	}
	Write-Host "Build Failed!" -ForegroundColor Red
	throw
}