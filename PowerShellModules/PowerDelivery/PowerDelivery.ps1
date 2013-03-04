Import-Module PowerDelivery -Force

if ($(get-host).version.major -lt 3) {
    Write-Error "Powershell 3.0 or greater is required."
    exit
}

if (!$dropLocation.EndsWith('\')) {
	$dropLocation = "$($dropLocation)\"
}

$global:pdlvry_assemblyInfoFiles = @()
$global:pdlvry_currentLocation = gl
$global:pdlvry_noReleases = $true
$global:pdlvry_envConfig = @()
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
$global:pdlvry_buildNumber = $null
$global:pdlvry_buildName = $null

function Require-NonNullField($variable, $errorMsg) {
	if ($variable -eq $null -or $variable -eq '') {
		throw $errorMsg;
	}
}

Write-Host
Write-Host "powerdelivery - https://github.com/eavonius/powerdelivery"

if ($environment -eq $null -or $environment -eq '') {
	$environment = "Local"
}

$buildConfig = "Debug"

function InvokePowerDeliveryBuildAction($condition, $methodName, $description, $status) {
    if (Get-Command $methodName -ErrorAction SilentlyContinue) {
        if ($condition) {
            Write-Host
		    Write-Host "$status..."
            Write-ConsoleSpacer
            Write-Host
            Invoke-Expression $methodName
		    Set-Location $global:pdlvry_currentLocation
        }
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

	Write-Host
    "Application"
    Write-ConsoleSpacer

    $appProperties = @{"App Name" = $appName; "App Version" = $buildAppVersion}

    Format-Table -InputObject $appProperties -AutoSize -HideTableHeaders

    "Parameters"
    Write-ConsoleSpacer

    $scriptParams = @{}

    $scriptParams["Requested By"] = $requestedBy
    $scriptParams["Environment"] = $environment

	if ($onServer) {
        $scriptParams["Team Collection"] = $collectionUri
        $scriptParams["Team Project"] = $teamProject
        $scriptParams["Change Set"] = $changeSet
        
        $buildNameSegments = $dropLocation.split('\') | where {$_}
        $buildNameIndex = $buildNameSegments.length - 1
        $buildName = $buildNameSegments[$buildNameIndex]
        $global:pdlvry_buildName = $buildName
        $scriptParams["Build Name"] = $buildName

        $buildNumber = $buildUri.Substring($buildUri.LastIndexOf("/") + 1)
        $global:pdlvry_buildNumber = $buildNumber
        $scriptParams["Build Number"] = $buildNumber
        
        if ($environment -ne "Local" -and $environment -ne "Commit") {
            $scriptParams["Prior Build"] = $priorBuild
        }

        $scriptParams["Drop Location"] = $dropLocation
	}

    $tableFormat = @{Expression={$_.Key};Label="Key";Width=50}, `
                   @{Expression={$_.Value};Label="Value";Width=75}

    $scriptParams | Format-Table $tableFormat -HideTableHeaders

    $vsInstallDir = Get-ItemProperty -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\10.0_Config -Name InstallDir
    if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
        throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
    }
    else {
        $ENV:Path += ";$($vsInstallDir.InstallDir)"
    }

	$envConfigFileName = $appScript + $environment + "Environment.csv"

	if (Test-Path -Path $envConfigFileName) {
		$global:pdlvry_envConfig = Import-Csv $envConfigFileName	
	}
	else {
		throw "Build configuration file $envConfigFileName not found."
	}

    $tableFormat = @{Expression={$_.Name};Label="Name";Width=50}, `
                   @{Expression={$_.Value};Label="Value";Width=75}

    "Environment"
    Write-ConsoleSpacer
    $global:pdlvry_envConfig | Format-Table $tableFormat -HideTableHeaders

	$releases = @()

    mkdir (Join-Path -Path $global:pdlvry_currentLocation -ChildPath 'PowerDeliveryBuildOutput') -Force | Out-Null

    InvokePowerDeliveryBuildAction -condition $true -methodName "Init" -description "initialization" -status "Initializing"
    
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreCompile" -description "pre-compilation" -status "Pre-Compiling"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "Compile" -description "compilation" -status "Compiling"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostCompile" -description "post-compilation" -status "Post-Compiling"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreTestUnits" -description "pre-unit testing" -status "Pre-Testing Units"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "TestUnits" -description "unit testing" -status "Testing Units"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostTestUnits" -description "post-unit testing" -status "Post-Testing Units"
    
    $projectCollection = $null
    $buildServer = $null
    $structure = $null

    if ($environment -ne "Local" -and $environment -ne "Commit" -and $onServer) {

        # copy files from the build being promoted 
        # out of the drop location of the previous 
        # pipeline environment and into the next one here.

        $vsVersion = "10.0"

        $vsInstallDir = Get-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\$($vsVersion)_Config" -Name InstallDir       
        if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
            throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
        }
        else {
            Write-Host "Adding $($vsInstallDir.InstallDir) to the PATH..."
            $ENV:Path += ";$($vsInstallDir.InstallDir)"
        }

        $refAssemblies = "ReferenceAssemblies\v2.0"
        $privateAssemblies = "PrivateAssemblies"
        $tfsAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.dll"
        $tfsClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Client.dll"
        $tfsBuildClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Build.Client.dll"
        $tfsBuildWorkflowAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$privateAssemblies\Microsoft.TeamFoundation.Build.Workflow.dll"
        $tfsVersionControlClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.VersionControl.Client.dll"
    
        "Loading TFS reference assemblies..."

        [Reflection.Assembly]::LoadFile($tfsClientAssembly) | Out-Null
        [Reflection.Assembly]::LoadFile($tfsBuildClientAssembly) | Out-Null
        [Reflection.Assembly]::LoadFile($tfsBuildWorkflowAssembly) | Out-Null
        [Reflection.Assembly]::LoadFile($tfsVersionControlClientAssembly) | Out-Null

        $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collectionUri)
        $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
        $structure = $projectCollection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])

        $priorBuildDetail = $buildServer.GetBuild("vstfs:///Build/Build/$priorBuild")
        $priorBuildDrop = $priorBuildDetail.DropLocation

        Write-Host "Copying prior build drop location output..."
        Copy-Item -Path "$priorBuildDrop\*" -Recurse -Destination "$dropLocation"
    }

    InvokePowerDeliveryBuildAction -condition $true -methodName "PreSetupEnvironment" -description "pre-setup environment" -status "Pre-Setting Up Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "SetupEnvironment" -description "setup environment" -status "Setting Up Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostSetupEnvironment" -description "post-setup environment" -status "Post-Setting Up Environment"
        
    InvokePowerDeliveryBuildAction -condition $true -methodName "PreDeploy" -description "pre-deploy" -status "Pre-Deploying"
    InvokePowerDeliveryBuildAction -condition $true -methodName "Deploy" -description "deploy" -status "Deploying"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostDeploy" -description "post-deploy" -status "Post-Deploying Environment"

    InvokePowerDeliveryBuildAction -condition $true -methodName "PreTestEnvironment" -description "pre-test environment" -status "Pre-Testing Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "TestEnvironment" -description "test environment" -status "Testing Environment"
    InvokePowerDeliveryBuildAction -condition $true -methodName "PostTestEnvironment" -description "post-test environment" -status "Post-Testing Environment"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PreTestAcceptance" -description "pre-acceptance testing" -status "Pre-Testing Acceptance"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "TestAcceptance" -description "acceptance testing" -status "Testing Acceptance"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -methodName "PostTestAcceptance" -description "post-acceptance testing" -status "Post-Testing Acceptance"

    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "PreTestCapacity" -description "pre-capacity testing" -status "Pre-Testing Capacity"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "TestCapacity" -description "capacity testing" -status "Testing Capacity"
    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -methodName "PostTestCapacity" -description "post-capacity testing" -status "Post-Testing Capacity"

	Write-Host "Build succeeded!" -ForegroundColor DarkGreen
}
catch {
	if ($onServer) {
		$buildDetail = Get-CurrentBuildDetail
		$buildDetail.FinalizeStatus([Microsoft.TeamFoundation.Build.Client.BuildStatus]::Failed)
	}

	Set-Location $global:pdlvry_currentLocation
	Write-Host "Build Failed!" -ForegroundColor Red
	throw
}