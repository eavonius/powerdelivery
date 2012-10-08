$global:cdry_spacer = "**************************************************************************"
$global:cdry_assemblyInfoFiles = @()
$global:cdry_currentLocation = gl
$global:cdry_noReleases = $true

Write-Host $global:cdry_spacer
Write-Host "powerdelivery Copyright (c) 2012 Jayme C. Edwards"
Write-Host "https://github.com/eavonius/powerdelivery"

if ($environment -eq $null -or $environment -eq '') {
	$environment = "Local"
}

$EnvConfig = @()
$buildConfig = "Debug"

function requireNonNullField($variable, $errorMsg) {
	if ($variable -eq $null -or $variable -eq '') {
		throw $errorMsg;
	}
}

function env-var($name) {
	ForEach ($envVar in $EnvConfig) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value;
		}
	}
	
	throw "Couldn't find environment variable named $name";
}

function Update-AssemblyInfoFiles {
	if ($environment -eq 'Development' -or $environment -eq 'Commit') {
	    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
		$changeSetNumber = $changeSet.Substring(1)
	    $assemblyVersion = 'AssemblyVersion(' + "$appVersion.$changeSetNumber" + ')'
	    $fileVersion = 'AssemblyFileVersion(' + "$appVersion.$changeSetNumber" + ')'
	    
	    Get-ChildItem -r -filter AssemblyInfo.cs | ForEach-Object {
	        $filename = $_.Directory.ToString() + '\' + $_.Name
			$global:cdry_assemblyInfoFiles += ,$filename
	        $filename + " -> $appVersion.$changeSetNumber"
	        Exec -errorMessage "Unable to checkout $filename from TFS" { 
				tf checkout $filename | Out-Null
			}
	        (Get-Content $filename) | ForEach-Object {
	            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
	            % {$_ -replace $fileVersionPattern, $fileVersion }
	        } | Set-Content $filename
	    }
	}
}

try {
	if ($onServer -eq $true) {
		requireNonNullField -variable $appVersion -errorMsg "appVersion variable is required when running on TFS"
		requireNonNullField -variable $changeSet -errorMsg "-changeSet parameter is required when running on TFS"
		requireNonNullField -variable $requestedBy -errorMsg "-requestedBy parameter is required when running on TFS"
		requireNonNullField -variable $teamProject -errorMsg "-teamProject parameter is required when running on TFS"
		requireNonNullField -variable $workspaceName -errorMsg "-workspaceName parameter is required when running on TFS"
		requireNonNullField -variable $environment -errorMsg "-environment parameter is required when running on TFS"
		
		$buildConfig = "Release"
	}
	else {
		$requestedBy = whoami
	}

	Write-Host $global:cdry_spacer
	Write-Host "Script Arguments"
	Write-Host "Running As: $(whoami)"
	Write-Host "Requested By: $requestedBy"
	Write-Host "Environment: $environment"
	Write-Host "Running on TFS Build: $onServer"
	Write-Host "Drop Location: $dropLocation"

	if ($onServer) {
		Write-Host "TFS Team Project: $teamProject"
		Write-Host "TFS Change Set: $changeSet"
		Write-Host "TFS Workspace: $workspaceName"
	}
	Write-Host $global:cdry_spacer
	
	cd PowerShellModules

	Write-Host "Importing Module PSake..."
	Import-Module .\psake

	cd ..

	Write-Host $global:cdry_spacer

	$ENV:Path += ";C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE"
	$ENV:Path += ";C:\Program Files (x86)\Microsoft Visual Studio 10.0\Team Tools\Performance Tools"
	$ENV:Path += ";C:\Windows\Microsoft.NET\Framework\v4.0.30319"

	if (Test-Path -Path "$($environment)Environment.csv") {
		$EnvConfig = Import-Csv "$($environment)Environment.csv"	
	}
	else {
		throw "Environment configuration file $($environment)Environment.csv not found."
	}

	Write-Host "Environment Configuration"
	ForEach ($envVar in $EnvConfig) {
		Write-Host "$($envVar.Name): $($envVar.Value)"
	}
	Write-Host $global:cdry_spacer

	$releases = @()

	if ($onServer) {
		$global:cdry_noReleases = tf dir "Releases.csv" | Select-String "No items match*"
		if (!$global:cdry_noReleases) {
			$releases = Import-Csv "Releases.csv"
			Exec -errorMessage "Unable to checkout Releases.csv" { 
				tf checkout "Releases.csv" | Out-Null
			}
		}
	}

	if (Get-Command "Compile" -ErrorAction SilentlyContinue and `
		($environment -eq 'Commit' -or $environment -eq 'Local')) {
		Write-Host "Compiling..."
		Compile
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No Compile() function found in script, skipping compile phase..."
	}

	if (Get-Command "SetupEnvironment" -ErrorAction SilentlyContinue) {
		Write-Host "Setting Up Environment..."
		SetupEnvironment
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No SetupEnvironment() function found in script, skipping environment setup phase..."
	}

	if (Get-Command "TestEnvironment" -ErrorAction SilentlyContinue) {
		Write-Host "Testing Environment..."
		TestEnvironment
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No TestEnvironment() function found in script, skipping environment testing phase..."
	}

	if (Get-Command "Deploy" -ErrorAction SilentlyContinue) {
		Write-Host "Deploying..."
		Deploy
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No Deploy() function found in script, skipping deployment phase..."
	}

	if (Get-Command "TestUnits" -ErrorAction SilentlyContinue and `
		($environment -eq 'Local' -or $environment -eq 'Commit' -or $environment -eq 'Development')) {
		Write-Host "Testing Units..."
		TestUnits
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No TestUnits() function found in script, skipping unit testing phase..."
	}

	if (Get-Command "TestAcceptance" -ErrorAction SilentlyContinue and `
		($environment -eq 'Local' -or $environment -eq 'Commit' -or $environment -eq 'Development')) {
		Write-Host "Testing Acceptance..."
		TestAcceptance
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No TestAcceptance() function found in script, skipping acceptance testing phase..."
	}

	if (Get-Command "TestCapacity" -ErrorAction SilentlyContinue and `
		($environment -eq 'CapacityTest')) {
		Write-Host "Testing Capacity..."
		TestCapacity
		Set-Location $global:cdry_currentLocation
		Write-Host $global:cdry_spacer
	}
	else {
		Write-Host "No TestCapacity() function found in script, skipping capacity testing phase..."
	}

	if ($onServer) {
		if ($environment -eq 'Development' -or $environment -eq 'Commit') {
			
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
			$releases | Export-Csv -NoTypeInformation -Path "Releases.csv"
		}
		if ($global:cdry_noReleases) {
			Exec -errorMessage "Unable to add Releases.csv to source control" { 
				tf add /noprompt "Releases.csv" | Out-Null
			}
		}
		Exec -errorMessage "Unable to checkin changes to releases and AssemblyInfo.cs versions" { 
			tf checkin /noprompt /author:"$requestedBy" /comment:"Updated releases and AssemblyInfo.cs version information." | Out-Null
		}
	}

	Write-Host "Build succeeded!" -ForegroundColor DarkGreen
}
Catch [System.Exception] {
	Set-Location $global:cdry_currentLocation
	if (!$global:cdry_noReleases) {
		Exec -errorMessage "Unable to undo checkout of Releases.csv" { 
			tf undo "Releases.csv" | Out-Null
		}
	}
	ForEach ($assemblyInfoFile in $global:cdry_assemblyInfoFiles) {
		Exec -errorMessage "Unable to undo checkout of $assemblyInfoFile" { 
			tf undo $assemblyInfoFile | Out-Null
		}
	}
	Write-Host "Build Failed!" -ForegroundColor Red
	
	throw
}