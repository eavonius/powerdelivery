<#
.Synopsis
Removes a powerdelivery build pipeline from a TFS project.

.Description
Removes a powerdelivery build pipeline from a TFS project. You will need to use source control history to 
recover your files if you accidentally remove a build pipeline using this cmdlet. The TFS security groups, 
TFS builds, PowerShell script, and YML configuration files associated with the pipeline will be removed.

.Example
Remove-Pipeline -name "MyApp" -collection "http://your-tfsserver/tfs" -project "My Project"

.Parameter name
The name of the product or component that will be no longer be delivered by this pipeline.

.Parameter collection
The URI of the TFS collection to remove powerdelivery from.

.Parameter project
The TFS project to remove powerdelivery from.
#>
function Remove-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=1)][string] $name,
        [Parameter(Mandatory=1)][string] $collection,
        [Parameter(Mandatory=1)][string] $project,
        [Parameter(Mandatory=0)][string] $vsVersion = "10.0"
    )
	
	$originalDir = Get-Location
	
	$moduleDir = $PSScriptRoot	
	
	$curDir = [System.IO.Path]::GetFullPath($moduleDir)
	$buildsDir = Join-Path -Path $curDir -ChildPath "Pipelines"
	
	try {
	    Write-Host
	    "Remove Pipeline Utility"
	    Write-Host
	    "powerdelivery - http://github.com/eavonius/powerdelivery"
	    Write-Host

	    if ($(get-host).version.major -lt 3) {
	        "Powershell 3.0 or greater is required."
	        exit
	    }

		LoadTFS -vsVersion $vsVersion

	    $outBaseDir = Join-Path -Path $buildsDir -ChildPath $project

        Remove-Item -Path $buildsDir -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

	    mkdir -Force $outBaseDir | Out-Null
	    cd $buildsDir

	    "Removing existing workspace at $collection if it exists..."
	    tf workspace /delete "AddPowerDelivery" /collection:"$collection" | Out-Null

	    if ($LASTEXITCODE -ne 0) {
	        Write-Host "NOTE: Error above is normal. This occurs if there wasn't a mapped working folder already."
	    }
		
		"Connecting to TFS server at $collection to delete builds..."

        $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($collection)
        $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
        $structure = $projectCollection.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])

		$buildServerVersion = $buildServer.BuildServerVersion
				
		if ($buildServerVersion -eq 'v3') {
			$powerdelivery.tfsVersion = '2010'
		}
		elseif ($buildServerVersion -eq 'v4') {
			$powerdelivery.tfsVersion = '2012'
		}
		else {
			throw "TFS server must be version 2010 or 2012, a different version was detected."
		}

        $projectInfo = $structure.GetProjectFromName($project)
        if (!$projectInfo) {
            Write-Error "Project $project not found in TFS collection $collection"
            exit
        }

		$buildDictionary = @{
            "$name - Local" = "Local";
            "$name - Commit" = "Commit";
            "$name - Test" = "Test";
            "$name - Capacity Test" = "CapacityTest";
            "$name - Production" = "Production";
        }
		
		$buildDictionary.GETENUMERATOR() | % {
            $buildName = $_.Key
            $buildEnv = $_.Value

            $build = $null

            if ($buildEnv -ne 'Local') {
			
				$buildExists = $false
                try {
                    $build = $buildServer.GetBuildDefinition($project, $buildName)
                    "Found build $buildName, checking for existing builds..."
					
					if ($buildServer.QueryBuilds($build).Length -gt 0) {
						$buildExists = $true
						throw "At least one build exists for $($buildName). You must delete these builds before the pipeline can be fully removed"
					}
                }
                catch {
					if ($buildExists) {
						throw
					}
				}
			}
		}
		
		$buildDictionary.GETENUMERATOR() | % {
            $buildName = $_.Key
            $buildEnv = $_.Value

            $build = $null

            if ($buildEnv -ne 'Local') {
                try {
                    $build = $buildServer.GetBuildDefinition($project, $buildName)
                    "Deleting build $($buildName)..."
					
					$buildServer.DeleteBuildDefinitions(
						@(New-Object -TypeName System.Uri -ArgumentList $build.Uri)
					);
                }
                catch {}
			}
		}

        "Creating TFS workspace for $collection..."
        tf workspace /new /noprompt "AddPowerDelivery" /collection:"$collection"

        "Getting files from project $project..."
        tf get "$project\*" /recursive /noprompt

		$scriptFileName = "$($name).ps1"
		if (Test-Path (Join-Path $outBaseDir $scriptFileName) -PathType Leaf) {
			tf delete "$project\$scriptFileName" /noprompt /recursive | Out-Null
		}
		
		$sharedConfigFileName = "$($name)Shared.yml"
		if (Test-Path (Join-Path $outBaseDir $sharedConfigFileName) -PathType Leaf) {
			tf delete "$project\$sharedConfigFileName" /noprompt /recursive | Out-Null
		}

		$buildDictionary.Values | % {
			$envName = $_
			$configFileName = "$($name)$($envName).yml"
			
			if (Test-Path (Join-Path $outBaseDir $configFileName) -PathType Leaf) {
				tf delete "$project\$configFileName" /noprompt /recursive | Out-Null
			}
		}
		
		"Checking in files removed from source control..."
		tf checkin "$project\*.*" /noprompt /recursive | Out-Null
		
		$groupSecurity = $projectCollection.GetService([Microsoft.TeamFoundation.Server.IGroupSecurityService])
        $appGroups = $groupSecurity.ListApplicationGroups($projectInfo.Uri)

        $buildDictionary.Values | % {
            $envName = $_
            if ($envName -ne 'Commit' -and $envName -ne 'Local') {
                $groupName = "$name $envName Builders"
                $appGroups | % {
                    if ($_.AccountName -eq $groupName) {
                        "Deleting TFS security group $groupName..."
                    	$groupSecurity.DeleteApplicationGroup($_.Sid) | Out-Null
                    }
                }
            }
        }
		
		Write-Host "Delivery pipeline '$name' removed from $collection for project '$project' successfully." -ForegroundColor Green
	}
	finally {
		try {
        	tf workspace /delete "AddPowerDelivery" /collection:"$collection" | Out-Null
		}
		catch {}
        del -Path $buildsDir -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
		cd $originalDir
    }	
}