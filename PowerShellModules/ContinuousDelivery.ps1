Import-Module ContinuousDelivery -Force

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
$global:pdlvry_piplineDB = $pipelineDB

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

try {
	if ($onServer -eq $true) {
		Require-NonNullField -variable $appVersion -errorMsg "appVersion variable is required when running on TFS"
		Require-NonNullField -variable $changeSet -errorMsg "-changeSet parameter is required when running on TFS"
		Require-NonNullField -variable $requestedBy -errorMsg "-requestedBy parameter is required when running on TFS"
		Require-NonNullField -variable $teamProject -errorMsg "-teamProject parameter is required when running on TFS"
		Require-NonNullField -variable $workspaceName -errorMsg "-workspaceName parameter is required when running on TFS"
		Require-NonNullField -variable $environment -errorMsg "-environment parameter is required when running on TFS"
		
		$buildConfig = "Release"
	}
	else {
		$requestedBy = whoami
	}

	Write-ConsoleSpacer
	Write-Host "Script Arguments"
	Write-Host "Running As: $(whoami)"
	Write-Host "Requested By: $requestedBy"
	Write-Host "Environment: $environment"
	Write-Host "Running on TFS Build: $onServer"
	
	if ($onServer) {
		Write-Host "Drop Location: $dropLocation"
		Write-Host "TFS Team Project: $teamProject"
		Write-Host "TFS Change Set: $changeSet"
		Write-Host "TFS Workspace: $workspaceName"
	}

	Write-ConsoleSpacer

	$ENV:Path += ";C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE"
	$ENV:Path += ";C:\Program Files (x86)\Microsoft Visual Studio 10.0\Team Tools\Performance Tools"
	$ENV:Path += ";C:\Windows\Microsoft.NET\Framework\v4.0.30319"

	if (Test-Path -Path "$($environment)Environment.csv") {
		$global:pdlvry_envConfig = Import-Csv "$($environment)Environment.csv"	
	}
	else {
		throw "Environment configuration file $($environment)Environment.csv not found."
	}

	Write-Host "Environment Configuration"
	ForEach ($envVar in $global:pdlvry_envConfig) {
		Write-Host "$($envVar.Name): $($envVar.Value)"
	}

	Write-ConsoleSpacer

	$releases = @()

	if (Get-Command "Compile" -ErrorAction SilentlyContinue and `
		($environment -eq 'Commit' -or $environment -eq 'Local')) {
		Write-Host "Compiling..."
		Compile
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No Compile() function found in script, skipping compile phase..."
	}

	if (Get-Command "SetupEnvironment" -ErrorAction SilentlyContinue) {
		Write-Host "Setting Up Environment..."
		SetupEnvironment
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No SetupEnvironment() function found in script, skipping environment setup phase..."
	}

	if (Get-Command "TestEnvironment" -ErrorAction SilentlyContinue) {
		Write-Host "Testing Environment..."
		TestEnvironment
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No TestEnvironment() function found in script, skipping environment testing phase..."
	}

	if (Get-Command "Deploy" -ErrorAction SilentlyContinue) {
		Write-Host "Deploying..."
		Deploy
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No Deploy() function found in script, skipping deployment phase..."
	}

	if (Get-Command "TestUnits" -ErrorAction SilentlyContinue and `
		($environment -eq 'Local' -or $environment -eq 'Commit')) {
		Write-Host "Testing Units..."
		TestUnits
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No TestUnits() function found in script, skipping unit testing phase..."
	}

	if (Get-Command "TestAcceptance" -ErrorAction SilentlyContinue and `
		($environment -eq 'Local' -or $environment -eq 'Commit')) {
		Write-Host "Testing Acceptance..."
		TestAcceptance
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No TestAcceptance() function found in script, skipping acceptance testing phase..."
	}

	if (Get-Command "TestCapacity" -ErrorAction SilentlyContinue and `
		($environment -eq 'CapacityTest')) {
		Write-Host "Testing Capacity..."
		TestCapacity
		Set-Location $global:pdlvry_currentLocation
		Write-ConsoleSpacer
	}
	else {
		Write-Host "No TestCapacity() function found in script, skipping capacity testing phase..."
	}

	if ($onServer) {
		if ($environment -ne 'Local') {
			
			# TODO: Update existing release in commit environment to reset environment
			$existingCommitRelease = $releases | Where-Object {$_.Environment -eq $environment}
			if ($existingCommitRelease) {
				$existingCommitRelease.Environment = ""
			}

			$release = New-Object PSObject -Property @{"ChangeSet" = $changeSet; `
													    "TeamProject" = $teamProject; `
													    "RequestedBy" = $requestedBy; `
													    "DropLocation" = $dropLocation; `
													    "Environment" = $environment; `
													    "IsUserAccepted" = $false; `
													    "IsCapacityTested" = $false}
			$releases += ,$release
			Write-Output "Created release $($release)"
			#$releases | Export-Csv -NoTypeInformation -Path "Releases.csv"
			
			# TODO: Write Database Row Here
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