function Write-ConsoleSpacer() {
    Write-Host "**************************************************************************"
}

function Get-BuildEnvironment() {
    return $global:pdlvry_environment
}

function Get-BuildDropLocation() {
    return $global:pdlvry_dropLocation
}

function Get-BuildChangeSet() {
    return $global:pdlvry_changeSet
}

function Get-BuildRequestedBy() {
    return $global:pdlvry_requestedBy
}

function Get-BuildTeamProject() {
    return $global:pdlvry_teamProject
}

function Get-BuildWorkspaceName() {
    return $global:pdlvry_workspaceName
}

function Get-BuildSetting($name) {
	ForEach ($envVar in $global:pdlvry_envConfig) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value
		}
	}
	
	throw "Couldn't find build setting '$name'"
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