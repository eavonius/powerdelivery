<#
.Synopsis
Adds a powerdelivery build pipeline to a TFS project from an example.

.Description
You need an existing TFS project that is empty already created and to have 
rights as a Project Administrator (to create builds, security groups, 
and add files to source control) to run this cmdlet.

.Example
Add-ExamplePipeline -example "ProductStoreTabular" -collection "http://your-tfsserver/tfs" -project "My Project" -controller "MyController" -dropFolder "\\SERVER\share"

.Parameter example
Optional. The name of an example folder in the Examples subdirectory of a powerdelivery Chocolatey installation. Either this or the examplePath parameter must be supplied.

.Parameter examplePath
Optional. The path to a custom example. Can be used to create new deployment pipelines from add your own starter projects. Either this or the example parameter must be supplied.

.Parameter outputPath
The path to map your working folder to work with the example.

.Parameter collection
The URI of the TFS collection to add the example to.

.Parameter project
The TFS project to add the example to.

.Parameter dropFolder
The folder compiled assets should go into from the pipeline.

.Parameter controller
The name of the TFS build controller the pipeline should use.

.Parameter vsVersion
Which version of the Visual Studio command-line tools to load for calling the TFS API. Set to "10.0" by default.
#>
function Add-ExamplePipeline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=0)][string] $example,
        [Parameter(Mandatory=0)][string] $examplePath,
        [Parameter(Mandatory=1)][string] $outputPath,
        [Parameter(Mandatory=1)][string] $collection,
        [Parameter(Mandatory=1)][string] $project,
        [Parameter(Mandatory=1)][string] $dropFolder,
        [Parameter(Mandatory=1)][string] $controller,
        [Parameter(Mandatory=0)][string] $vsVersion = "10.0"
    )

    $originalDir = Get-Location
    
    $moduleDir = $PSScriptRoot  
    
    $curDir = [System.IO.Path]::GetFullPath($moduleDir)

    if (!(Test-Path -Path $outputPath)) {
        Write-Error "Output path '$outputPath' does not exist."
        exit
    }

    $outBaseDir = Join-Path -Path $outputPath -ChildPath $project

    if ([String]::IsNullOrWhiteSpace($example) -eq $false) {
        $exampleDir = Join-Path -Path $curDir -ChildPath "..\Examples\$example"
    }
    elseif ([String]::IsNullOrWhiteSpace($exampleDir)) {
        Write-Error "Example or example directory must be specified."
        exit
    }

    if (!(Test-Path -Path $exampleDir)) {
        Write-Error "Example '$exampleDir' does not exist."
        exit
    }

    $name = Split-Path $exampleDir -Leaf

    try {
        Write-Host
        "Add Example Pipeline Utility"
        Write-Host
        "powerdelivery - http://github.com/eavonius/powerdelivery"
        Write-Host

        if ($(get-host).version.major -lt 3) {
            "Powershell 3.0 or greater is required."
            exit
        }

        LoadTFS -vsVersion $vsVersion    

        Remove-Item -Path $outBaseDir -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

        mkdir -Force $outBaseDir | Out-Null
        cd $outputPath

        $computerName = $env:COMPUTERNAME

        "Creating TFS working folder for $project in $collection..."
        tf workfold /map "`$/$project" $outBaseDir /collection:"$collection" /workspace:"$computerName"

        "Getting files from project $project..."
        tf get "$project\*" /recursive /noprompt
        tf checkout /recursive "$project\*"

        "$exampleDir -> $outBaseDir"
        Copy-Item -Recurse -Path "$exampleDir\*" -Destination $outBaseDir -Force | Out-Null
        Copy-Item -Path (Join-Path -Path $curDir -ChildPath "BuildProcessTemplates") -Recurse -Destination "$outBaseDir" -Force

        $newScriptName = "$outBaseDir\$name.ps1"

        $buildDictionary = @{
            "$name - Local" = "Local";
            "$name - Commit" = "Commit";
            "$name - Test" = "Test";
            "$name - Capacity Test" = "CapacityTest";
            "$name - Production" = "Production";
        }
        
        "Checking in changed or new files to source control..."
        tf add "$project\*.*" /noprompt /recursive | Out-Null
        tf checkin "$project\*.*" /noprompt /recursive | Out-Null

        "Connecting to TFS server at $collection to create builds..."

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
        #>
        Write-Host "Delivery pipeline '$name' ready at $collection for project '$project'" -ForegroundColor Green
    }
    finally {
        cd $originalDir
    }
}