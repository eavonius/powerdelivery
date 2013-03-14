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

			Write-BuildSummaryMessage -name "Compile" -header "Compilations" -message "MSBuild: $projectFile ($flavor - $buildConfiguration)"
            "TFS build information saved."
        }

        Write-ConsoleSpacer
    }
}