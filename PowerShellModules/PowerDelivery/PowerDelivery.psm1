[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

function Write-ConsoleSpacer() {
    Write-Host "============================================================================================="
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

function Invoke-EnvironmentCommand($server, $command, $credential) {

    $invokeExpression = $null
    if ($server -ne $null -and $credential -ne $null) {
		Write-Host
		"Command on $($server): $command"
        $invokeExpression = "Invoke-Command -ComputerName $server -ScriptBlock { $command } -Authentication CredSSP -credential $credential"
    }
    elseif ($server -ne $null) {
		"Command on $($server): $command"
        $invokeExpression = "Invoke-Command -ComputerName $server -ScriptBlock { $command }"
    }
    else {
        $command
        $invokeExpression = "Invoke-Expression $command"
    }
	
    return Invoke-Expression -Command $invokeExpression -ErrorAction Stop
}

function Invoke-SSISPackage($package, $server, $version = "110", $packageArgs) {

	$getSqlInstallDir = "Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\110 -Name VerSpecificRootDir"
	$sqlInstallDir = Invoke-EnvironmentCommand -server $server -command $getSqlInstallDir

	if ([string]::IsNullOrWhiteSpace($sqlInstallDir)) {
        throw "SQL $version does not appear to be installed on $server."
    }
	
	$dtExecPath = Join-Path -Path $sqlInstallDir -ChildPath "DTS\Binn\Dtexec.exe"
	
	$packageExecStatement = "& ""$dtExecPath"" /File '$package'"
	
	if ($packageArgs) {
		$packageExecStatment += " $packageArgs"
	}
	
	Invoke-EnvironmentCommand -server $server -command $packageExecStatement
}

function Stop-SqlJobs($serverName, $jobs) {

	Write-Host
    "Disabling SQL jobs with pattern $($jobs)* on $serverName"
	Write-Host

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.Isenabled -eq $true -and  $_.name -like "$($jobs)*"}

    $jobRunning = $false
    $jobName = ''

    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
        if ($dataMartJob.CurrentRunStatus.ToString() -ne 'Idle') {
            $jobRunning = $true
            break
        }	
        else {	
            $dataMartJob.IsEnabled = $false
            $dataMartJob.Alter()
            "Job '$jobName' successfully disabled."
        }
    }

    if ($jobRunning) {
        foreach ($dataMartJob in $dataMartJobs)	{	
            $dataMartJob.IsEnabled = $true
            $dataMartJob.Alter()
        }
        throw "Job '$jobName' is still running, stopping build."
    }
}

function Start-SqlJobs($serverName, $jobs) {

	Write-Host
    "Enabling SQL jobs with pattern $($jobs)* on $serverName"
	Write-Host

    $dataMartServer = New-Object Microsoft.SqlServer.Management.SMO.Server("$serverName")
    $dataMartJobs = $dataMartServer.jobserver.jobs | where-object {$_.name -like "$($jobs)*"}
    foreach ($dataMartJob in $dataMartJobs)	{	
        $jobName = $dataMartJob.Name
        $dataMartJob.IsEnabled = $true
        $dataMartJob.Alter()
        "Job '$jobName' successfully enabled."
    }
}

function Mount-IfUNC($path) {
	
	if ($path.StartsWith("\\")) {
		$uncPathWithoutBackslashes = $path.Substring(2)
		$pathSegments = $uncPathWithoutBackslashes -split "\\"
		$uncPath = "\\$($pathSegments[0])\$($pathSegments[1])"
	}
}

function Invoke-MSTest($list, $vsmdi, $settings, $results, $platform) {

    $currentDirectory = Get-Location
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation

	$localResults = "$currentDirectory\$results"
	$dropResults = "$dropLocation\$results"

    if ([String]::IsNullOrWhiteSpace($platform)) {
		$platform = AnyCPU
	}

	try {
        # Run acceptance tests out of local directory
        Exec {
            mstest /testmetadata:"$dropLocation\$vsmdi" `
                   /testlist:"$list" `
                   /testsettings:"$dropLocation\$settings" `
                   /resultsfile:"$localResults"
                   /usestderr /nologo
        }
    }
    finally {
        if (Test-Path $localResults -PathType Leaf) {

            copy $localResults $dropResults

            # Publish acceptance test results for this build to the TFS server
            Exec {
                mstest /publish:"$(Get-CollectionUri)" `
                       /teamproject:"$(Get-BuildTeamProject)" `
                       /publishbuild:"$(Get-BuildName)" `
                       /publishresultsfile:"$dropResults" `
                       /flavor:$environment `
                       /platform:$platform `
					   /nologo
            }
        }
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
	$scriptsDir = Join-Path -Path (Get-BuildDropLocation) -ChildPath "Databases\$database"

	if ($environment -eq "Local" -or $environment -eq "Commit") {
		Write-Host "Dropping database $database on $server..."
		Exec -ErrorAction Stop { 
			rh --silent /s=$server /d=$database /f="$scriptsDir" /env=$environment /o=Databases\$database\output /drop
		}
	}
}

# Runs database script migrations against a target database 
# using RoundhousE to bring it up to the latest version of changes.
#
function Publish-Roundhouse($server, $database) {
	
    $environment = Get-BuildEnvironment
	$scriptsDir = Join-Path -Path (Get-BuildDropLocation) -ChildPath "Databases\$database"

	Write-Host "Running database migrations on $database on $server..."
	Exec -ErrorAction Stop { 
		rh --silent /s=$server /d=$database /f="$scriptsDir" /env=$environment /o=Databases\$database\output /simple
	}
}

function Roundhouse($database, $server, $scriptsDir, $restorePath, $restoreOptions) {

    $environment = Get-BuildEnvironment

	Write-Host "Running database migrations on $server\$database"

    $command = "rh --silent /vf=""sql"" /s=$server /d=$database /f=""$scriptsDir"" /env=$environment /o=Databases\$database\output /simple"
    
    if ($environment -ne 'Production' -and ![String]::IsNullOrWhitespace($restorePath)) {
        $command += " --restore --restorefrompath=""$restorePath"""
        if (![String]::IsNullOrWhiteSpace($restoreOptions)) {
            $command += " --restorecustomoptions=""$restoreOptions"""
        }
    }

	Exec -ErrorAction Stop { 
	    Invoke-Expression -Command $command	
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

function Invoke-MSBuild($projectFile, $properties, $target, $toolsVersion, `
                        $verbosity = "m", $buildConfiguration = "Debug", $flavor = "AnyCPU", `
                        $ignoreProjectExtensions, $dotNetVersion = "4.0") {

    $regKey = "HKLM:\Software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
    $regProperty = "MSBuildToolsPath"

    $msbuildExe = Join-Path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"

    $msBuildCommand = "& ""$msbuildExe"""
    $msBuildCommand += " ""/nologo"""

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

	if (![string]::IsNullOrWhiteSpace($target)) {
		$msBuildCommand += " ""/T:$target"""
	}

    $msBuildCommand += " ""$projectFile"""

	Write-Host
    "Compiling MSBuild Project:"
	Write-ConsoleSpacer
	Write-Host
	
    "Project File: $projectFile"
    "Configuration: $buildConfiguration"
    "Platform(s): $flavor"
    "Build .NET Version: $dotNetVersion"

    if (![string]::IsNullOrWhiteSpace($ignoreProjectExtensions)) {
        "Ignoring Extensions: $ignoreProjectExtensions"
    }

    if (![string]::IsNullOrWhiteSpace($toolsVersion)) {
        "Tools Version: $toolsVersion"
    }

	if (![string]::IsNullOrWhiteSpace($target)) {
		"Target: $target"
	}

    if ($properties -ne $null) {
        if ($properties.length -gt 0) {
            Write-Host "Build Properties:"
            Write-Host $properties
        }
    }

    try {
        Exec {
            Invoke-Expression $msBuildCommand
        }
    }
    finally {
        if (Get-BuildOnServer) {
            
            Update-AssemblyInfoFiles -path ([System.IO.Path]::GetDirectoryName($projectFile))

            $buildDetail = Get-CurrentBuildDetail

            $projectFileName = [System.IO.Path]::GetFileName($projectFile)
            $tfsPath = "`$/$($projectFile.Replace('\', '/'))"

            "Uploading MSBuild information to TFS for $tfsPath"

            $publishTarget = "Default"
            if (![string]::IsNullOrWhiteSpace($target)) {
		        $publishTarget = $target
	        }

            $buildProjectNode = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddBuildProjectNode(`
                $buildDetail.Information, [DateTime]::Now, $buildConfiguration, $projectFile, $flavor, $tfsPath, [DateTime]::Now, $publishTarget)

            $buildProjectNode.Save()

            $buildDetail.Information.Save()

            "TFS build information saved."
        }

        Write-ConsoleSpacer
    }
}

function Publish-SSAS($asDatabase, $computer, $tabularServer, $sqlVersion = '11.0') {

    #$utilityInstallDir = Invoke-EnvironmentCommand -server $server -credential $credential `
        #-command "Get-ItemProperty -Path ""Registry::HKEY_CURRENT_USER\Software\Microsoft\SQL Server Management Studio\$($sqlVersion)_Config"" -Name InstallDir"

    $asUtilityPath = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Microsoft.AnalysisServices.Deployment.exe"

    $asModelName = [System.IO.Path]::GetFileNameWithoutExtension($asDatabase)
    $asFilesDir = [System.IO.Path]::GetDirectoryName($asDatabase)
    $xmlaPath = Join-Path -Path $asFilesDir -ChildPath "$($asModelName).xmla"

    $remoteCommand = "& ""$asUtilityPath"" ""$asDatabase"" ""/d"" ""/o:$xmlaPath"" | Out-Null"

    Invoke-EnvironmentCommand -server $computer -command $remoteCommand

    $remoteCommand = "Invoke-ASCMD -server ""$tabularServer"" -inputFile ""$xmlaPath"""

    Invoke-EnvironmentCommand -server $computer -command $remoteCommand
}

function Set-SSASConnection($computer, $tabularServer, $databaseName, $datasourceID, $connectionName, $connectionString) {

    $query = @"
    <Alter ObjectExpansion=""ObjectProperties"" xmlns=""http://schemas.microsoft.com/analysisservices/2003/engine"">
	    <Object>
		    <DatabaseID>$databaseName</DatabaseID>
		    <DataSourceID>$datasourceID</DataSourceID>
	    </Object>
	    <ObjectDefinition>
		    <DataSource xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" 
					    xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" 
					    xmlns:ddl2=""http://schemas.microsoft.com/analysisservices/2003/engine/2"" 
					    xmlns:ddl2_2=""http://schemas.microsoft.com/analysisservices/2003/engine/2/2"" 
					    xmlns:ddl100_100=""http://schemas.microsoft.com/analysisservices/2008/engine/100/100"" 
					    xmlns:ddl200=""http://schemas.microsoft.com/analysisservices/2010/engine/200"" 
					    xmlns:ddl200_200=""http://schemas.microsoft.com/analysisservices/2010/engine/200/200"" 
					    xmlns:ddl300=""http://schemas.microsoft.com/analysisservices/2011/engine/300"" 
					    xmlns:ddl300_300=""http://schemas.microsoft.com/analysisservices/2011/engine/300/300"" 
					    xsi:type=""RelationalDataSource"">
			    <Name>$connectionName</Name>
			    <ConnectionString>$connectionString</ConnectionString>
		    </DataSource>
	    </ObjectDefinition>
    </Alter>
"@

    $command = "Invoke-ASCMD -server $tabularServer -query ""$query"""
    Invoke-EnvironmentCommand -server $computer -command $command
}