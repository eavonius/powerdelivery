<#
PowerDelivery.psm1

powerdelivery - http://eavonius.github.com/powerdelivery

PowerShell module that enables writing build scripts that follow continuous delivery 
principles and deploy product assets into multiple environments.
#>

[Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

function Write-ConsoleSpacer() {
    "============================================================================================="
}

function Get-BuildOnServer {
    [CmdletBinding()]
    param()
    return $powerdelivery.onServer
}

function Get-BuildAppVersion {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildAppVersion;
}

function Get-BuildEnvironment {
    [CmdletBinding()]
    param()
    return $powerdelivery.environment
}

function Get-BuildDropLocation {
    [CmdletBinding()]
    param()
    return $powerdelivery.dropLocation
}

function Get-BuildChangeSet {
    [CmdletBinding()]
    param()
    return $powerdelivery.changeSet
}

function Get-BuildRequestedBy {
    [CmdletBinding()]
    param()
    return $powerdelivery.requestedBy
}

function Get-BuildTeamProject {
    [CmdletBinding()]
    param()
    return $powerdelivery.teamProject
}

function Get-BuildWorkspaceName {
    [CmdletBinding()]
    param()
    return $powerdelivery.workspaceName
}

function Get-CollectionUri {
    [CmdletBinding()]
    param()
    return $powerdelivery.collectionUri
}

function Get-BuildUri {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildUri
}

function Get-BuildNumber {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildNumber
}

function Get-BuildName {
    [CmdletBinding()]
    param()
    return $powerdelivery.buildName
}

function Get-BuildSetting {
    [CmdletBinding()]
    param([Parameter(Position=0,Mandatory=1)][string] $name)

	ForEach ($envVar in $powerdelivery.envConfig) {
		if ($envVar.Name -eq $name) {
			return $envVar.Value
		}
	}
	throw "Couldn't find build setting '$name'"
}

function Invoke-EnvironmentCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=1)][string] $command, 
        [Parameter(Mandatory=0)] $credential
    )

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

function Invoke-SSISPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $package, 
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=0)][string] $version = "110", 
        [Parameter(Mandatory=0)][string] $packageArgs
    )

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

function Stop-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $serverName, 
        [Parameter(Mandatory=1)][string] $jobs
    )

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

function Start-SqlJobs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $serverName, 
        [Parameter(Mandatory=1)][string] $jobs
    )

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

function Mount-IfUNC {
    [CmdletBinding()]
    param([Parameter(Mandatory=1)][string] $path)
	
	if ($path.StartsWith("\\")) {
		$uncPathWithoutBackslashes = $path.Substring(2)
		$pathSegments = $uncPathWithoutBackslashes -split "\\"
		$uncPath = "\\$($pathSegments[0])\$($pathSegments[1])"
	}
}

function Invoke-MSTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $list, 
        [Parameter(Mandatory=1)][string] $vsmdi, 
        [Parameter(Mandatory=1)][string] $settings, 
        [Parameter(Mandatory=1)][string] $results, 
        [Parameter(Mandatory=0)][string] $platform = 'AnyCPU'
    )

    $currentDirectory = Get-Location
	$environment = Get-BuildEnvironment
	$dropLocation = Get-BuildDropLocation

	$localResults = "$currentDirectory\$results"
	$dropResults = "$dropLocation\$results"

	try {
        # Run acceptance tests out of local directory
        Exec -errorMessage "Error running tests in list $list using $vsmdi" {
            mstest /testmetadata:"$currentDirectory\$vsmdi" `
                   /testlist:"$list" `
                   /testsettings:"$currentDirectory\$settings" `
                   /resultsfile:"$localResults" `
                   /usestderr /nologo
        }
    }
    finally {
        if ((Test-Path $localResults -PathType Leaf) -and $powerdelivery.onServer) {

            copy $localResults $dropResults

            # Publish acceptance test results for this build to the TFS server
            Exec -errorMessage "Error publishing test results for $dropResults" {
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

function Enable-WebDeploy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $webComputer, 
        [Parameter(Mandatory=1)][string] $webDeployDir, 
        [Parameter(Mandatory=1)][string] $webSite, 
        [Parameter(Mandatory=1)][string] $webPort, 
        [Parameter(Mandatory=1)][string] $webPassword, 
        [Parameter(Mandatory=0)][string] $runtimeVersion = '4.0'
    )

    $webDeployScriptsDir = "$webDeployDir\Scripts"
    $siteSetupArgs = "-siteName $webSite -publishSettingSavePath C:\Inetpub\$webSite -publishSettingFileName $($webSite).publishsettings -sitePhysicalPath C:\Inetpub\$webSite -sitePort $webPort -siteAppPoolName $webSite -deploymentUserName $webSite -deploymentUserPassword '$($webPassword)' -managedRunTimeVersion v$runtimeVersion"
    $setupSiteResult = Invoke-Expression -Command "Invoke-Command -ComputerName $webComputer -ScriptBlock { & ""$webDeployScriptsDir\SetupSiteForPublish.ps1"" $siteSetupArgs }"
}

function Update-AssemblyInfoFiles {
    [CmdletBinding()]
    param([Parameter(Mandatory=1)][string] $path)

	if ($environment -eq 'Development' -or $environment -eq 'Commit') {
        $buildAppVersion = Get-BuildAppVersion
	    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $assemblyVersion = "AssemblyVersion(""$buildAppVersion"")"
	    $fileVersion = "AssemblyFileVersion(""$buildAppVersion"")"
	    
	    Get-ChildItem -r -Path $path -filter AssemblyInfo.cs | ForEach-Object {
	        $filename = $_.Directory.ToString() + '\' + $_.Name
			$powerdelivery.assemblyInfoFiles += ,$filename
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
function Remove-Roundhouse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=1)][string] $database
    )

    $environment = Get-BuildEnvironment
	$scriptsDir = Join-Path -Path (Get-BuildDropLocation) -ChildPath "Databases\$database"

	if ($environment -eq "Local" -or $environment -eq "Commit") {
		"Dropping database $database on $server..."
		Exec -ErrorAction Stop { 
			rh --silent /s=$server /d=$database /f="$scriptsDir" /env=$environment /o=Databases\$database\output /drop
		}
	}
}

# Runs database script migrations against a target database 
# using RoundhousE to bring it up to the latest version of changes.
#
function Publish-Roundhouse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $server, 
        [Parameter(Mandatory=1)][string] $database
    )
	
    $environment = Get-BuildEnvironment
	$scriptsDir = Join-Path -Path (Get-BuildDropLocation) -ChildPath "Databases\$database"

	"Running database migrations on $database on $server..."
	Exec -ErrorAction Stop { 
		rh --silent /s=$server /d=$database /f="$scriptsDir" /env=$environment /o=Databases\$database\output /simple
	}
}

function Invoke-Roundhouse {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $database, 
        [Parameter(Position=1,Mandatory=1)][string] $server, 
        [Parameter(Position=2,Mandatory=1)][string] $scriptsDir, 
        [Parameter(Position=3,Mandatory=0)][string] $restorePath, 
        [Parameter(Position=4,Mandatory=0)][string] $restoreOptions
    )

    $environment = Get-BuildEnvironment

	"Running database migrations on $server\$database"

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
	$tfsAssemblyPath = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.dll"
	$tfsClientAssemblyPath = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll"
    $tfsBuildClientAssemblyPath = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Build.Client.dll"

	[Reflection.Assembly]::LoadFile($tfsAssemblyPath) | Out-Null
    [Reflection.Assembly]::LoadFile($tfsClientAssemblyPath) | Out-Null
    [Reflection.Assembly]::LoadFile($tfsBuildClientAssemblyPath) | Out-Null

    $collectionUri = Get-CollectionUri

    "Connecting to TFS server at $collectionUri..."

    $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collectionUri)
    $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])

    $buildUri = Get-BuildUri
    "Opening Information for Build $buildUri..."

    return $buildServer.GetBuild($buildUri)
}

function Write-BuildSummaryMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $name, 
        [Parameter(Mandatory=1)][string] $header, 
        [Parameter(Mandatory=1)][string] $message
    )
    
    # TODO: Check for TFS 2012 and allow
    if ($false) {
        $buildDetail = Get-CurrentBuildDetail

        $buildSummaryMessage = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation(`
            $buildDetail.Information, $message, $name, $header, 0)

        $buildSummaryMessage.Save()

        $buildDetail.Information.Save()
    }
}

function Invoke-MSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $projectFile, 
        [Parameter(Mandatory=0)] $properties, 
        [Parameter(Mandatory=0)][string] $target, 
        [Parameter(Mandatory=0)][string] $toolsVersion, 
        [Parameter(Mandatory=0)][string] $verbosity = "m", 
        [Parameter(Mandatory=0)][string] $buildConfiguration = "Debug", 
        [Parameter(Mandatory=0)][string] $flavor = "AnyCPU", 
        [Parameter(Mandatory=0)][string] $ignoreProjectExtensions, 
        [Parameter(Mandatory=0)][string] $dotNetVersion = "4.0"
    )

	$dropLocation = Get-BuildDropLocation
	$logFolder = Join-Path $dropLocation "Logs"
	mkdir -Force $logFolder | Out-Null

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
	
	$logFile = [IO.Path]::GetFileNameWithoutExtension($projectFile) + ".log"
	
	$msBuildCommand += " ""/l:FileLogger,Microsoft.Build.Engine;logfile=$logFile"""

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

	$tableFormat = @{Expression={$_.Key};Label="Key";Width=50}, `
                   @{Expression={$_.Value};Label="Value";Width=75}

    if ($properties -ne $null) {
        if ($properties.length -gt 0) {
            "Build Properties:"
			$properties | Format-Table $tableFormat -HideTableHeaders
        }
    }

    if (Get-BuildOnServer) {
			
		$fullProjectFile = [System.IO.Path]::Combine($currentDirectory, [System.IO.Path]::GetFileName($projectFile))
	    Update-AssemblyInfoFiles -path ([System.IO.Path]::GetDirectoryName($fullProjectFile))
	}


    try {
        Exec -errorMessage "Invocation of MSBuild project $projectFile failed." {
            Invoke-Expression $msBuildCommand
        }
    }
    finally {
        if (Get-BuildOnServer) {
     
            $buildDetail = Get-CurrentBuildDetail

            $projectFileName = [System.IO.Path]::GetFileName($projectFile)
            $tfsPath = "`$/$($projectFile.Replace('\', '/'))"

            "Uploading MSBuild information to TFS for $tfsPath"

            $publishTarget = "Default"
            if (![string]::IsNullOrWhiteSpace($target)) {
		        $publishTarget = $target
	        }
			
			$logFilename = [IO.Path]::GetFileName($logFile)
			$logDestFile = Join-Path $logFolder $logFilename
			
			copy $logFile $logDestFile

            $buildProjectNode = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddBuildProjectNode(`
                $buildDetail.Information, [DateTime]::Now, $buildConfiguration, $projectFile, $flavor, $tfsPath, [DateTime]::Now, $publishTarget)
				
			$errorCount = 0
			$warningCount = 0
						
			Get-Content $logFile | Where-Object {$_ -like "*error*"} | ForEach-Object { 
				if ($_ -match "^.*(?=: error)") {
					$errorCount++
					
					$parensStart = $Matches[0].IndexOf('(')
					$parensEnd = $Matches[0].IndexOf(')')
					$lineSep = $Matches[0].IndexOf(',')
					
					$errorStart = $_.IndexOf(": error")
					
					$fileName = ""
					$lineNumber = 0
					$lineCharacter = 0
					
					if ($parensStart -eq -1 -or $parensEnd -eq -1) {
						$fileName = $Matches[0].Substring(0, $errorStart)
					}
					else {
						$fileName = $Matches[0].Substring(0, $parensStart)
						$lineNumber = $Matches[0].Substring($parensStart + 1, $lineSep - ($parensStart + 1))
						$lineCharacter = $Matches[0].Substring($lineSep + 1, $parensEnd - ($lineSep + 1))
					}
					
					$buildError = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddBuildError(`
						$buildProjectNode.Node.Children, "Compilation", $fileName, $lineNumber, $lineCharacter, "", $_.Substring($errorStart + 2), [DateTime]::Now)
				}
			}
			
			Get-Content $logFile | Where-Object {$_ -like "*warning*"} | ForEach-Object { 
				if ($_ -match "^.*(?=: warning)") {
					$warningCount++
					
					$parensStart = $Matches[0].IndexOf('(')
					$parensEnd = $Matches[0].IndexOf(')')
					$lineSep = $Matches[0].IndexOf(',')
					
					$warningStart = $_.IndexOf(": warning")
					
					$fileName = ""
					$lineNumber = 0
					$lineCharacter = 0
					
					if ($parensStart -eq -1 -or $parensEnd -eq -1) {
						$fileName = $Matches[0].Substring(0, $warningStart)
					}
					else {
						$fileName = $Matches[0].Substring(0, $parensStart)
						$lineNumber = $Matches[0].Substring($parensStart + 1, $lineSep - ($parensStart + 1))
						$lineCharacter = $Matches[0].Substring($lineSep + 1, $parensEnd - ($lineSep + 1))
					}
					
					$buildWarning = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddBuildWarning(`
						$buildProjectNode.Node.Children, $fileName, $lineNumber, $lineCharacter, "", $_.Substring($warningStart + 2), [DateTime]::Now, "Compilation")
				}
			}
			
			$buildProjectNode.CompilationErrors = $errorCount
			$buildProjectNode.CompilationWarnings = $warningCount

			$logDestUri = New-Object -TypeName System.Uri -ArgumentList $logDestFile

			$logFileLink = [Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddExternalLink(`
				$buildProjectNode.Node.Children, "Log File", $logDestUri)

            $buildProjectNode.Save()

            $buildDetail.Information.Save()

            "TFS build information saved."
        }

        Write-ConsoleSpacer
    }
}

function Publish-SSAS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $asDatabase, 
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=1)][string] $tabularServer, 
        [Parameter(Mandatory=0)][string] $sqlVersion = '11.0'
    )

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

function Set-SSASConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=1)][string] $computer, 
        [Parameter(Mandatory=1)][string] $tabularServer, 
        [Parameter(Mandatory=1)][string] $databaseName, 
        [Parameter(Mandatory=1)][string] $datasourceID, 
        [Parameter(Mandatory=1)][string] $connectionName, 
        [Parameter(Mandatory=1)][string] $connectionString
    )

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

function Require-NonNullField($variable, $errorMsg) {
	if ($variable -eq $null -or $variable -eq '') {
		throw $errorMsg;
	}
}

function Exec {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ("Error executing command {0}" -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}

function InvokePowerDeliveryBuildAction($condition, $stage, $description, $status) {
    if ($condition -and $stage) {
        Write-Host
	    "$status..."
        Write-ConsoleSpacer
        Write-Host
        & $stage
	    Set-Location $powerdelivery.currentLocation
    }
}

function Init {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.init = $action
}

function Compile {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.compile = $action
}

function Deploy {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.deploy = $action
}

function SetupEnvironment {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.setupEnvironment = $action
}

function TestEnvironment {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testEnvironment = $action
}

function TestUnits {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testUnits = $action
}

function TestAcceptance {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testAcceptance = $action
}

function TestCapacity {
	[CmdletBinding()]
	param([Parameter(Position=0, Mandatory=1)][scriptblock] $action)
	
	$powerdelivery.testCapacity = $action
}

function Pipeline {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=1)][string] $scriptName,
		[Parameter(Mandatory=1)][string] $version
	)
	
	$powerdelivery.pipeline = $this
	$powerdelivery.scriptName = $scriptName

	$buildAppVersion = "$appVersion"
	
    if ($environment -ne 'local') {
	    $changeSetNumber = $powerdelivery.changeSet.Substring(1)
	    $buildAppVersion = "$version." + $changeSetNumber
    }
	else {
		$buildAppVersion = $version
	}

    $powerdelivery.buildAppVersion = $buildAppVersion
}

function Invoke-Powerdelivery {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][string] $buildScript,
        [Parameter(Position=1,Mandatory=0)][switch] $onServer = $false,
	    [Parameter(Position=2,Mandatory=0)][string] $dropLocation,
	    [Parameter(Position=3,Mandatory=0)][string] $changeSet,
	    [Parameter(Position=4,Mandatory=0)][string] $requestedBy,
	    [Parameter(Position=5,Mandatory=0)][string] $teamProject,
	    [Parameter(Position=6,Mandatory=0)][string] $workspaceName,
	    [Parameter(Position=7,Mandatory=0)][string] $environment = 'Local',
        [Parameter(Position=8,Mandatory=0)][string] $buildUri,
        [Parameter(Position=9,Mandatory=0)][string] $collectionUri,
	    [Parameter(Position=10,Mandatory=0)][string] $priorBuild
    )
	
	$ErrorActionPreference = 'Stop'

    if (!$dropLocation.EndsWith('\')) {
	    $dropLocation = "$($dropLocation)\"
    }

    $powerdelivery.assemblyInfoFiles = @()
    $powerdelivery.currentLocation = gl
    $powerdelivery.noReleases = $true
    $powerdelivery.envConfig = @()
    $powerdelivery.environment = $environment
    $powerdelivery.dropLocation = $dropLocation
    $powerdelivery.changeSet = $changeSet
    $powerdelivery.requestedBy = $requestedBy
    $powerdelivery.teamProject = $teamProject
    $powerdelivery.workspaceName = $workspaceName
    $powerdelivery.collectionUri = $collectionUri
    $powerdelivery.buildUri = $buildUri
    $powerdelivery.onServer = $onServer
    $powerdelivery.buildNumber = $null
    $powerdelivery.buildName = $null

    Write-Host
    "powerdelivery - https://github.com/eavonius/powerdelivery"
	Write-Host
	$appScript = [System.IO.Path]::GetFileNameWithoutExtension($buildScript)

    try {
		if ($onServer -eq $true) {

		    Require-NonNullField -variable $changeSet -errorMsg "-changeSet parameter is required when running on TFS"
		    Require-NonNullField -variable $requestedBy -errorMsg "-requestedBy parameter is required when running on TFS"
		    Require-NonNullField -variable $teamProject -errorMsg "-teamProject parameter is required when running on TFS"
		    Require-NonNullField -variable $workspaceName -errorMsg "-workspaceName parameter is required when running on TFS"
		    Require-NonNullField -variable $environment -errorMsg "-environment parameter is required when running on TFS"
            Require-NonNullField -variable $collectionUri -errorMsg "-collectionUri parameter is required when running on TFS"
            Require-NonNullField -variable $buildUri -errorMsg "-buildUri parameter is required when running on TFS"
            Require-NonNullField -variable $dropLocation -errorMsg "-dropLocation parameter is required when running on TFS"
	    }
	    else {
		    $powerdelivery.requestedBy = whoami
			$currentDirectory = Get-Location
			$powerdelivery.dropLocation = [System.IO.Path]::Combine($currentDirectory, "$($appScript)BuildDrop")
			mkdir $powerdelivery.dropLocation -Force | Out-Null
	    }
		
		$envConfigFileName = $appScript + $environment + "Environment.csv"

	    if (Test-Path -Path $envConfigFileName) {
		    $powerdelivery.envConfig = Import-Csv $envConfigFileName	
	    }
	    else {
		    throw "Build configuration file $envConfigFileName not found."
	    }
		
		Invoke-Expression -Command ".\$appScript"
		
		Write-Host
	    "Application"
	    Write-ConsoleSpacer

	    $appProperties = @{"App Name" = $appScript; "App Version" = $powerdelivery.buildAppVersion}

	    Format-Table -InputObject $appProperties -AutoSize -HideTableHeaders

	    "Parameters"
	    Write-ConsoleSpacer

	    $scriptParams = @{}

	    $scriptParams["Requested By"] = $powerdelivery.requestedBy
	    $scriptParams["Environment"] = $powerdelivery.environment
		
		if ($onServer) {
	        $scriptParams["Team Collection"] = $powerdelivery.collectionUri
	        $scriptParams["Team Project"] = $powerdelivery.teamProject
	        $scriptParams["Change Set"] = $powerdelivery.changeSet
	    
	        $buildNameSegments = $powerdelivery.dropLocation.split('\') | where {$_}
	        $buildNameIndex = $buildNameSegments.length - 1
	        $buildName = $buildNameSegments[$buildNameIndex]
	        $powerdelivery.buildName = $buildName
	        $scriptParams["Build Name"] = $powerdelivery.buildName

	        $buildNumber = $powerdelivery.buildUri.Substring($buildUri.LastIndexOf("/") + 1)
	        $powerdelivery.buildNumber = $buildNumber
	        $scriptParams["Build Number"] = $buildNumber
	    
	        if ($powerdelivery.environment -ne "Local" -and $powerdelivery.environment -ne "Commit") {
	            $scriptParams["Prior Build"] = $powerdelivery.priorBuild
	        }
	    }
		
		$scriptParams["Drop Location"] = $powerdelivery.dropLocation
		
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

	    $tableFormat = @{Expression={$_.Name};Label="Name";Width=50}, `
	                   @{Expression={$_.Value};Label="Value";Width=75}

	    "Environment"
	    Write-ConsoleSpacer
	    $powerdelivery.envConfig | Format-Table $tableFormat -HideTableHeaders

	    $releases = @()

	    #mkdir (Join-Path -Path $powerdelivery.currentLocation -ChildPath 'PowerDeliveryBuildOutput') -Force | Out-Null

		InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.init -description "initialization" -status "Initializing"
	    InvokePowerDeliveryBuildAction -condition ($powerdelivery.environment -eq 'Commit' -or $powerdelivery.environment -eq 'Local') -stage $powerdelivery.compile -description "compilation" -status "Compiling"
	    InvokePowerDeliveryBuildAction -condition ($powerdelivery.environment -eq 'Commit' -or $powerdelivery.environment -eq 'Local') -stage $powerdelivery.testUnits -description "unit testing" -status "Testing Units"
		
		$projectCollection = $null
	    $buildServer = $null
	    $structure = $null

	    if ($powerdelivery.environment -ne "Local" -and $powerdelivery.environment -ne "Commit" -and $powerdelivery.onServer) {

	        # copy files from the build being promoted 
	        # out of the drop location of the previous 
	        # pipeline environment and into the next one here.

	        $vsVersion = "10.0"

	        $vsInstallDir = Get-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\$($vsVersion)_Config" -Name InstallDir       
	        if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
	            throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
	        }
	        else {
	            "Adding $($vsInstallDir.InstallDir) to the PATH..."
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

	        $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($powerdelivery.collectionUri)
	        $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
	        $structure = $projectCollection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])

	        $priorBuildDetail = $buildServer.GetBuild("vstfs:///Build/Build/$priorBuild")
	        $priorBuildDrop = $priorBuildDetail.DropLocation

	        "Copying prior build drop location output..."
	        Copy-Item -Path "$priorBuildDrop\*" -Recurse -Destination $powerdelivery.dropLocation
	    }

	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.setupEnvironment -description "setup environment" -status "Setting Up Environment"    
	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.deploy -description "deploy" -status "Deploying"
	    InvokePowerDeliveryBuildAction -condition $true -stage $powerdelivery.testEnvironment -description "test environment" -status "Testing Environment"
	    InvokePowerDeliveryBuildAction -condition ($environment -eq 'Commit' -or $environment -eq 'Local') -stage $powerdelivery.testAcceptance -description "acceptance testing" -status "Testing Acceptance"
	    InvokePowerDeliveryBuildAction -condition ($environment -eq 'CapacityTest') -stage $powerdelivery.testCapacity -description "capacity testing" -status "Testing Capacity"
        
	    Write-Host "Build succeeded!" -ForegroundColor DarkGreen
    }
    catch {
	    Set-Location $powerdelivery.currentLocation
	    Write-Host "Build Failed!" -ForegroundColor Red
		throw
    }
}

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}

function Add-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=1)][string] $name,
        [Parameter(Mandatory=1)][string] $collection,
        [Parameter(Mandatory=1)][string] $project,
        [Parameter(Mandatory=1)][string] $dropFolder,
        [Parameter(Mandatory=1)][string] $controller,
        [Parameter(Mandatory=0)][string] $template = "Blank",
        [Parameter(Mandatory=0)][string] $vsVersion = "10.0",
        [Parameter(Mandatory=0)][string] $tfsVersion = "2010",
        [Parameter(Mandatory=0)][switch] $force = $false,
        [Parameter(Mandatory=0)][switch] $upgrade = $false
    )
	
	$originalDir = Get-Location
	
	$moduleDir = $PSScriptRoot	
	
	$curDir = [System.IO.Path]::GetFullPath($moduleDir)
	
	try {
	    Write-Host
	    "Add Pipeline Utility"
	    Write-Host
	    "powerdelivery - http://github.com/eavonius/powerdelivery"
	    Write-Host

	    if ($(get-host).version.major -lt 3) {
	        "Powershell 3.0 or greater is required."
	        exit
	    }

	    function RequireParam($param, $switch) {
	        if ([string]::IsNullOrWhiteSpace($param)) {
	            Write-Error "$switch was not supplied"
	            exit
	        }
	    }

	    RequireParam -param $name -switch  "-name"
	    RequireParam -param $template -switch  "-templateName"
	    RequireParam -param $collection -switch  "-tfsCollectionUri"
	    RequireParam -param $project -switch  "-tfsProjectName"
	    RequireParam -param $vsVersion -switch "-vsVersion"
	    RequireParam -param $controller -switch "-buildController"
	    RequireParam -param $dropFolder -switch "-dropFolder"

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

	    $buildsDir = Join-Path -Path $curDir -ChildPath "Pipelines"
	    $outBaseDir = Join-Path -Path $buildsDir -ChildPath $project

	    del -Path $buildsDir -Force -Recurse | Out-Null
	    mkdir -Force $outBaseDir | Out-Null
	    cd $buildsDir

	    "Removing existing workspace at $collection if it exists..."
	    tf workspace /delete "AddPowerDelivery" /collection:"$collection" | Out-Null

	    if ($LASTEXITCODE -ne 0) {
	        Write-Host "NOTE: Error above is normal. This occurs if there wasn't a mapped working folder already."
	    }

        "Creating TFS workspace for $collection..."
        tf workspace /new /noprompt "AddPowerDelivery" /collection:"$collection"

        "Getting files from project $project..."
        tf get "$project\*" /recursive /noprompt

        $templateDir = Join-Path -Path $curDir -ChildPath "Templates\$template"

        if (!(Test-Path -Path $templateDir)) {
            Write-Error "Template '$template' does not exist."
            exit
        }

        "$templateDir -> $outBaseDir"
        Copy-Item -Recurse -Path "$templateDir\*" -Destination $outBaseDir -Force | Out-Null
        Copy-Item -Path (Join-Path -Path $curDir -ChildPath "BuildProcessTemplates") -Recurse -Destination "$outBaseDir" -Force

        $newScriptName = "$outBaseDir\$name.ps1"

        Move-Item -Path "$outBaseDir\Build.ps1" -Destination "$newScriptName" -Force
        Move-Item -Path "$outBaseDir\BuildLocalEnvironment.csv" -Destination "$outBaseDir\$($name)LocalEnvironment.csv" -Force
        Move-Item -Path "$outBaseDir\BuildCommitEnvironment.csv" -Destination "$outBaseDir\$($name)CommitEnvironment.csv" -Force
        Move-Item -Path "$outBaseDir\BuildTestEnvironment.csv" -Destination "$outBaseDir\$($name)TestEnvironment.csv" -Force
        Move-Item -Path "$outBaseDir\BuildCapacityTestEnvironment.csv" -Destination "$outBaseDir\$($name)CapacityTestEnvironment.csv" -Force
        Move-Item -Path "$outBaseDir\BuildProductionEnvironment.csv" -Destination "$outBaseDir\$($name)ProductionEnvironment.csv" -Force

        "Replacing build template variables..."
        (Get-Content "$newScriptName") | Foreach-Object {
            $_ -replace '%BUILD_NAME%', $name
        } | Set-Content "$newScriptName"

        "Checking in changed or new files to source control..."
        tf add "$project\*.*" /noprompt /recursive | Out-Null
        tf checkin "$project\*.*" /noprompt /recursive | Out-Null

        "Connecting to TFS server at $collectionUri to create builds..."

        $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collection)
        $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
        $structure = $projectCollection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])

        $projectInfo = $structure.GetProjectFromName($project)
        if (!$projectInfo) {
            Write-Error "Project $project not found in TFS collection $collection"
            exit
        }

        $buildDictionary = @{
            "$name - Commit" = "Commit";
            "$name - Test" = "Test";
            "$name - Capacity Test" = "CapacityTest";
            "$name - Production" = "Production";
        }

        $buildDictionary.GETENUMERATOR() | % {
            $buildName = $_.Key
            $buildEnv = $_.Value

            $build = $null

            try {
                $build = $buildServer.GetBuildDefinition($project, $buildName)
                "Found build $buildName, updating..."
            }
            catch {
                "Creating build $buildName..."
            
                $build = $buildServer.CreateBuildDefinition($project)
            }
            
            $build.Name = $buildName

            if ($buildName.EndsWith("Commit")) {
                $build.ContinuousIntegrationType = [Microsoft.TeamFoundation.Build.Client.ContinuousIntegrationType]::Individual
            }
            else {
                $build.ContinuousIntegrationType = [Microsoft.TeamFoundation.Build.Client.ContinuousIntegrationType]::None
            }

            $build.BuildController = $buildServer.GetBuildController($controller)

            $buildFound = $false

		    $processTemplatePath = "`$/$project/BuildProcessTemplates/PowerDeliveryTemplate.xaml"
            $changeSetTemplatePath = "`$/$project/BuildProcessTemplates/PowerDeliveryChangeSetTemplate.xaml"

		    if ($tfsVersion -eq "2012") {
        	    $processTemplatePath = "`$/$project/BuildProcessTemplates/PowerDeliveryTemplate.11.xaml"
			    $changeSetTemplatePath = "`$/$project/BuildProcessTemplates/PowerDeliveryChangeSetTemplate.11.xaml"
		    }

            $processTemplates = $buildServer.QueryProcessTemplates($project)

            foreach ($processTemplate in $processTemplates) {
                if ($processTemplate.ServerPath -eq $processTemplatePath -and $buildEnv -eq "Commit") {
                    $build.Process = $processTemplate
                    $buildFound = $true
                    break
                }
                elseif ($processTemplate.ServerPath -eq $changeSetTemplatePath -and $buildEnv -ne "Commit") {
                    $build.Process = $processTemplate
                    $buildFound = $true
                    break
                }
            }

            $build.DefaultDropLocation = $dropFolder

            if (!$buildFound) {

                if ($buildEnv -eq "Commit") {
                    $templateToCreate = $processTemplatePath
                }
                else {
                    $templateToCreate = $changeSetTemplatePath
                }

                "Creating build process template for $templateToCreate..."
                $processTemplate = $buildServer.CreateProcessTemplate($project, $templateToCreate)
                $processTemplate.TemplateType = [Microsoft.TeamFoundation.Build.Client.ProcessTemplateType]::Custom
                "Saving process template..."
                $processTemplate.Save()
                "Done"

                if ($processTemplate -eq $null) {
                    throw "Couldn't find a process template at $templateToCreate"
                }
                $build.Process = $processTemplate
            }

            $processParams = [Microsoft.TeamFoundation.Build.Workflow.WorkflowHelpers]::DeserializeProcessParameters($build.ProcessParameters)
            $processParams["Environment"] = $buildEnv        
            $scriptPath = "`$/$project/$($name).ps1"
            $processParams["PowerShellScriptPath"] = $scriptPath
        
            $build.ProcessParameters = [Microsoft.TeamFoundation.Build.Workflow.WorkflowHelpers]::SerializeProcessParameters($processParams)

            $build.Save()
        }

        $groupSecurity = $projectCollection.GetService([Microsoft.TeamFoundation.Server.IGroupSecurityService])
        $appGroups = $groupSecurity.ListApplicationGroups($projectInfo.Uri)

        $buildDictionary.Values | ForEach-Object {
            $envName = $_
            if ($envName -ne 'Commit') {
                $groupName = "$name $envName Builders"
                $group = $null
                $appGroups | ForEach-Object {
                    if ($_.AccountName -eq $groupName) {
                        $group = $_
                    }
                }

                if (!$group) {
                    "Creating TFS security group $groupName..."
                    $groupSecurity.CreateApplicationGroup($projectInfo.Uri, $groupName, "Members of this group can queue $name builds targeting the $envName environment.") | Out-Null
                }
            }
        }

        "Delivery pipeline '$name' ready at $collection for project '$project'" 
    }
    finally {
        cd $curDir
        tf workspace /delete "AddPowerDelivery" /collection:"$collection" | Out-Null
        del -Path $buildsDir -Force -Recurse |Out-Null
		cd $originalDir
    }
}

$script:powerdelivery = @{}
$powerdelivery.build_success = $true
$powerdelivery.pipeline = $null