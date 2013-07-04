<#
.Synopsis
Adds a powerdelivery build pipeline to a TFS project.

.Description
You can enable a Microsoft Team Foundation Server project to use powerdelivery in under a minute using this cmdlet. It allows you to select from one of several included templates as a starting point, and creates builds targeting each environment on Team Foundation Server with a powerdelivery PowerShell script for you to automate deployment. You can run this cmdlet multiple times specifying a different name each time to create a delivery pipeline for each software product you wish to deploy independently.

.Example
Add-Pipeline -name "MyApp" -collection "http://your-tfsserver/tfs" -project "My Project" -controller "MyController" -dropFolder "\\SERVER\share"

.Parameter name
The name of the product or component that will be delivered by this pipeline.

.Parameter collection
The URI of the TFS collection to add powerdelivery to.

.Parameter project
The TFS project to add powerdelivery to.

.Parameter dropFolder
The folder compiled assets should go into from the pipeline.

.Parameter controller
The name of the TFS build controller the pipeline should use.

.Parameter template
Optional. The name of a directory within the "Templates" directory of wherever you installed powerdelivery to (usually C:\Chocolatey\lib\powerdelivery<version>). The default is "Blank". A template minimally must have the following files:

Build.ps1
BuildLocalEnvironment.csv
BuildCommitEnvironment.csv
BuildTestEnvironment.csv
BuildCapacityTestEnvironment.csv
BuildProductionEnvironment.csv

Check out the templates page on the wiki (https://github.com/eavonius/powerdelivery/wiki/Templates) for more about which to use.
#>
function Add-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=1)][string] $name,
        [Parameter(Mandatory=1)][string] $collection,
        [Parameter(Mandatory=1)][string] $project,
        [Parameter(Mandatory=1)][string] $dropFolder,
        [Parameter(Mandatory=1)][string] $controller,
        [Parameter(Mandatory=0)][string] $template = "Blank",
        [Parameter(Mandatory=0)][string] $vsVersion = "10.0"
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

		LoadTFS -vsVersion $vsVersion

	    $buildsDir = Join-Path -Path $curDir -ChildPath "Pipelines"
	    $outBaseDir = Join-Path -Path $buildsDir -ChildPath $project

        Remove-Item -Path $buildsDir -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

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
		
		$buildDictionary = @{
            "$name - Local" = "Local";
            "$name - Commit" = "Commit";
            "$name - Test" = "Test";
            "$name - Capacity Test" = "CapacityTest";
            "$name - Production" = "Production";
        }
		
		$envExtensions = @(".yml", ".csv")
		
		$buildDictionary.Values | % {
			$envName = $_
			$envExtensions | % {
				$envExtension = $_
				$sourcePath = "$outBaseDir\Build$($envName)Environment$($envExtension)"
				$destPath = "$outBaseDir\$($name)$($envName)Environment$($envExtension)"
				if (Test-Path $sourcePath) {
					Move-Item -Force $sourcePath $destPath
				}
			}
		}
		
        "Replacing build template variables..."
        (Get-Content "$newScriptName") | % {
            $_ -replace '%BUILD_NAME%', $name
        } | Set-Content "$newScriptName"

        "Checking in changed or new files to source control..."
        tf add "$project\*.*" /noprompt /recursive | Out-Null
        tf checkin "$project\*.*" /noprompt /recursive | Out-Null

        "Connecting to TFS server at $collectionUri to create builds..."

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

        $buildDictionary.GETENUMERATOR() | % {
            $buildName = $_.Key
            $buildEnv = $_.Value

            $build = $null

            if ($buildEnv -ne 'Local') {
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

		        if ($powerdelivery.tfsVersion -eq 2012) {
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
        }

        $groupSecurity = $projectCollection.GetService([Microsoft.TeamFoundation.Server.IGroupSecurityService])
        $appGroups = $groupSecurity.ListApplicationGroups($projectInfo.Uri)

        $buildDictionary.Values | % {
            $envName = $_
            if ($envName -ne 'Commit' -and $envName -ne 'Local') {
                $groupName = "$name $envName Builders"
                $group = $null
                $appGroups | % {
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