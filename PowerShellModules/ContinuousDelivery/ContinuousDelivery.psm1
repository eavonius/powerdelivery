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

function Get-BuildEnvironmentSetting($name) {
	ForEach ($envVar in $global:pdlvry_buildSettings) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value
		}
	}
	
	throw "Couldn't find build environment setting '$name'"
}

function Update-AssemblyInfoFiles {
	if ($environment -eq 'Development' -or $environment -eq 'Commit') {
	    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $assemblyVersion = 'AssemblyVersion(' + "$buildAppVersion" + ')'
	    $fileVersion = 'AssemblyFileVersion(' + "$buildAppVersion" + ')'
	    
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
		return $buildAppVersion
	}
	return ""
}

function Invoke-MSBuild($projectFile, $outDir, $properties, $toolsVersion, $verbosity, $ignoreProjectExtensions, $dotNetVersion = "4.0") {

    $regKey = "HKLM:\Software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
    $regProperty = "MSBuildToolsPath"

    $msbuildExe = Join-Path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"

    $msBuildCommand = "& ""$msbuildExe"""

    if (strlen($outDir) -ne 0) {
        $msBuildCommand += " ""/p:OutDir=""$outDir"""""
    }
    else {
        $msBuildCommand += " ""/p:OutDir=""$(Get-BuildDropLocation)"""""
    }

    if ($properties -ne $null) {
        if ($properties.length -gt 0) {
            
            $properties.Keys | % {
                $msBuildCommand += " ""/p:$($_)=""$($properties.Item($_))"""""
            }
        }
    }

    if (strlen($toolsVersion) -ne 0) {
        $msBuildCommand += " ""/tv:$toolsVersion"""
    }

    if (strlen($verbosity) -ne 0) {
        $msBuildCommand += " ""/v:$verbosity"""
    }

    if (strlen($ignoreProjectExtensions) -ne 0) {
        $msBuildCommand += " ""/ignore:$ignoreProjectExtensions"""
    }

    $msBuildCommand += " ""$projectFile"""

    Write-Host $msBuildCommand

    Invoke-Expression -Command $msBuildCommand
}