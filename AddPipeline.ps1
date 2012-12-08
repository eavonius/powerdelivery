# AddPipeline.ps1
#
# Creates a pipeline of builds in TFS from a powerdelivery template.

Param (
    [string]
    $name,
    [string]
    $template = "Blank",
    [string]
    $collection,
    [string]
    $project,
    [string]
    $dropFolder,
    [string]
    $controller,
    [string]
    $vsVersion = "10.0"
)

Write-Host
"Add Pipeline Utility"
Write-Host
"powerdelivery - http://github.com/eavonius/powerdelivery"
Write-Host

if ($(get-host).version.major -lt 3) {
    "Powershell 3.0 or greater is required."
    exit
}

$curDir = Get-Location
$modulesDir = Join-Path -Path $curDir -ChildPath "PowerShellModules"
$psakeDir = Join-Path -Path $modulesDir -ChildPath "psake"

"Checking for psake..."
if (!(Test-Path -Path $psakeDir)) {
    Write-Error "Download psake from https://github.com/psake/psake/archive/master.zip and extract it as ./PowerShellModules/psake"
    exit
}

$env:PSModulePath += ";.\PowerShellModules"

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

if (Test-Path -Path $outBaseDir) {
    Remove-Item -Path $outBaseDir -Force -Recurse | Out-Null
}

mkdir -Force $outBaseDir | Out-Null
cd $buildsDir

"Removing existing workspace at $collection if it exists..."
tf workspace /delete "AddPowerDelivery" /collection:"$collection" | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "NOTE: Error above is normal. This occurs if there wasn't a mapped working folder already."
}

try {
    "Creating TFS workspace for $collection..."
    tf workspace /new /noprompt "AddPowerDelivery" /collection:"$collection"

    "Getting files from project $project..."
    tf get "$project\*" /recursive /overwrite /noprompt

    $templateDir = Join-Path -Path $curDir -ChildPath "Templates\$template"

    if (!(Test-Path -Path $templateDir)) {
        Write-Error "Template '$template' does not exist."
        exit
    }

    "$templateDir -> $outBaseDir"
    Copy-Item -Recurse -Path "$templateDir\*" -Destination $outBaseDir -Force | Out-Null
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerDeliveryEnvironment.csv") -Destination "$outBaseDir" -Force
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "BuildProcessTemplates") -Recurse -Destination "$outBaseDir" -Force
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerShellModules") -Recurse -Destination "$outBaseDir" -Force

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
    tf add *.* /noprompt /recursive
    tf checkin /noprompt /recursive

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
}