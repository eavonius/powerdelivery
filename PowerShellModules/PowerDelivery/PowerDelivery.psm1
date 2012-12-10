function Write-ConsoleSpacer() {
    Write-Host "**************************************************************************"
}

function Get-BuildOnServer() {
    return $global:pdlvry_onServer
}

function Get-BuildAppVersion() {
    return $global:pdlvry_buildAppVersion;
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

function Get-CollectionUri() {
    return $global:pdlvry_collectionUri
}

function Get-BuildUri() {
    return $global:pdlvry_buildUri
}

function Get-BuildNumber() {
    return $global:pdlvry_buildNumber
}

function Get-BuildName() {
    return $global:pdlvry_buildName
}

function Get-BuildSetting($name) {
	ForEach ($envVar in $global:pdlvry_envConfig) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value
		}
	}
	
	throw "Couldn't find build setting '$name'"
}

function Mount-IfUNC($path) {
	
	if ($path.StartsWith("\\")) {
		$uncPathWithoutBackslashes = $path.Substring(2)
		$pathSegments = $uncPathWithoutBackslashes -split "\\"
		$uncPath = "\\$($pathSegments[0])\$($pathSegments[1])"
	}
}

function Update-AssemblyInfoFiles($path) {
	if ($environment -eq 'Development' -or $environment -eq 'Commit') {
        $buildAppVersion = Get-BuildAppVersion
	    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $assemblyVersion = 'AssemblyVersion(' + "$buildAppVersion" + ')'
	    $fileVersion = 'AssemblyFileVersion(' + "$buildAppVersion" + ')'
	    
	    Get-ChildItem -r -Path $path -filter AssemblyInfo.cs | ForEach-Object {
	        $filename = $_.Directory.ToString() + '\' + $_.Name
			$global:pdlvry_assemblyInfoFiles += ,$filename
	        $filename + " -> $appVersion.$changeSetNumber"
	        Exec -errorMessage "Unable to update file attributes on $filename" { 
                attrib -r "$filename"
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

# Drops database when deploying against local or commit environment.
#
function Remove-Roundhouse($server, $database) {

    $environment = Get-BuildEnvironment

	if ($environment -eq "Local" -or $environment -eq "Commit") {
		Write-Host "Dropping database $database on $server..."
		Exec -ErrorAction Stop -Verbose { 
			rh --silent /s=$server /d=$database /f=Databases\$database /env=$environment /o=Databases\$database\output /drop
		}
	}
}

# Runs database script migrations against a target database 
# using RoundhousE to bring it up to the latest version of changes.
#
function Publish-Roundhouse($server, $database) {
	
    $environment = Get-BuildEnvironment

	Write-Host "Running database migrations on $database on $server..."
	Exec -ErrorAction Stop -Verbose { 
		rh --silent /s=$server /d=$database /f=Databases\$database /env=$environment /o=Databases\$database\output /simple
	}
}

function Get-CurrentBuildDetail {

    $vsInstallDir = Get-ItemProperty -Path Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\10.0_Config -Name InstallDir       
    $tfsClientAssemblyPath = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll"
    $tfsBuildClientAssemblyPath = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Build.Client.dll"

    [Reflection.Assembly]::LoadFile($tfsClientAssemblyPath) | Out-Null
    [Reflection.Assembly]::LoadFile($tfsBuildClientAssemblyPath) | Out-Null

    $collectionUri = Get-CollectionUri

    Write-Host "Connecting to TFS server at $collectionUri..."

    $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collectionUri)
    $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])

    $buildUri = Get-BuildUri
    Write-Host "Opening Information for Build $buildUri..."

    return $buildServer.GetBuild($buildUri)
}

function Write-BuildSummaryMessage($name, $header, $message) {
    
    # TODO: Check for TFS 2012 and allow
    if ($false) {
        $buildDetail = Get-CurrentBuildDetail

        $buildSummaryMessage = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation(`
            $buildDetail.Information, $message, $name, $header, 0)

        $buildSummaryMessage.Save()

        $buildDetail.Information.Save()
    }
}

function Invoke-MSBuild($projectFile, $outDir, $properties, $toolsVersion, `
                        $verbosity = "m", $buildConfiguration = "Debug", $flavor = "x86", `
                        $ignoreProjectExtensions, $dotNetVersion = "4.0") {

    $regKey = "HKLM:\Software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
    $regProperty = "MSBuildToolsPath"

    $msbuildExe = Join-Path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"

    $msBuildCommand = "& ""$msbuildExe"""
    $msBuildCommand += " ""/nologo"""

    $buildOutputDir = "PowerDeliveryBuildOutput\"

    if ([string]::IsNullOrWhiteSpace($outDir)) {
        Remove-Item -Path "$buildOutputDir*"
        $outDir = $buildOutputDir
    }
        
    $msBuildCommand += " ""/p:OutDir=$outDir"""

    if ($properties -ne $null) {
        if ($properties.length -gt 0) {
            
            $properties.Keys | % {
                $msBuildCommand += " ""/p:$($_)=$($properties.Item($_))"""
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($toolsVersion) -eq $false) {
        $msBuildCommand += " ""/tv:$toolsVersion"""
    }

    if ([string]::IsNullOrWhiteSpace($verbosity) -eq $false) {
        $msBuildCommand += " ""/v:$verbosity"""
    }

    if ([string]::IsNullOrWhiteSpace($ignoreProjectExtensions) -eq $false) {
        $msBuildCommand += " ""/ignore:$ignoreProjectExtensions"""
    }

    $msBuildCommand += " ""$projectFile"""

    Write-ConsoleSpacer

    Write-Host "Compiling MSBuild Project:"
    Write-Host "Project File: $projectFile"
    Write-Host "Output Directory: $outDir"
    Write-Host "Configuration: $buildConfiguration"
    Write-Host "Platform(s): $flavor"
    Write-Host "Build .NET Version: $dotNetVersion"

    if (![string]::IsNullOrWhiteSpace($ignoreProjectExtensions)) {
        Write-Host "Ignoring Extensions: $ignoreProjectExtensions"
    }

    if (![string]::IsNullOrWhiteSpace($toolsVersion)) {
        Write-Host "Tools Version: $toolsVersion"
    }

    if ($properties -ne $null) {
        if ($properties.length -gt 0) {
            Write-Host "Build Properties:"
            Write-Host $properties
        }
    }

    try {
        Invoke-Expression -Command $msBuildCommand

        Copy-Item -Recurse -Filter *.* $buildOutputDir Get-BuildDropLocation
    }
    finally {
        if (Get-BuildOnServer) {
            
            Update-AssemblyInfoFiles -path ([System.IO.Path]::GetDirectoryName($projectFile))

            $buildDetail = Get-CurrentBuildDetail

            $projectFileName = [System.IO.Path]::GetFileName($projectFile)
            $tfsPath = "`$/$($projectFile.Replace('\', '/'))"

            Write-Host "Uploading MSBuild information to TFS for $tfsPath"

            $buildProjectNode = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddBuildProjectNode(`
                $buildDetail.Information, [DateTime]::Now, $buildConfiguration, $projectFileName, $flavor, $tfsPath, [DateTime]::Now, "Default")

            $buildProjectNode.Save()

            $buildDetail.Information.Save()

            Write-Host "TFS build information saved."
        }

        Write-ConsoleSpacer
    }
}

function Publish-SSAS($asFiles, $logFile, $server, $credentials, $sqlVersion = '11.0') {

    $utilityInstallDir = Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\SQL Server Management Studio\$($sqlVersion)_Config" -Name MsEnvLocation
    
    $deploySSASCommand = "& ""$msEnvLocation\Microsoft.AnalysisServices.Deployment.exe"" ""$asFiles"" ""/s:"" ""$logFile"""
    
    Write-Host "Publishing SSAS models in $asFiles to $server using SQL $sqlVersion..."

    if ($server -ne $null -and $credentials -ne $null) {
        Invoke-Command -ComputerName $server -Script { $deploySSASCommand } -Authentication CredSSP -Credential credentials
    }
    elsif ($server -ne $null) {
        Invoke-Command -ComputerName $server -Script { $deploySSASCommand }
    }
    else {
        Invoke-Expression $deploySSASCommand
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Error deploying one or more model. See $logFile for more details."
    }
}