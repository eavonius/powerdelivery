# NewProject.ps1
#
# Creates a new project from one of the templates and adds it to TFS.

Param (
    [string]
    $name,
    [string]
    $templateName = "Blank",
    [string]
    $tfsCollectionUri,
    [string]
    $tfsProjectName,
    [string]
    $buildController,
    [string]
    $vsVersion = "10.0"
)

Write-Host
"New Project Generation Utility"
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
RequireParam -param $templateName -switch  "-templateName"
RequireParam -param $tfsCollectionUri -switch  "-tfsCollectionUri"
RequireParam -param $tfsProjectName -switch  "-tfsProjectName"
RequireParam -param $vsVersion -switch "-vsVersion"
RequireParam -param $buildController -switch "-buildController"

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
$tfsClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Client.dll"
$tfsBuildClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Build.Client.dll"
$tfsBuildWorkflowAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$privateAssemblies\Microsoft.TeamFoundation.Build.Workflow.dll"
$tfsVersionControlClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.VersionControl.Client.dll"

"Loading TFS reference assemblies..."

[Reflection.Assembly]::LoadFile($tfsClientAssembly) | Out-Null
[Reflection.Assembly]::LoadFile($tfsBuildClientAssembly) | Out-Null
[Reflection.Assembly]::LoadFile($tfsBuildWorkflowAssembly) | Out-Null
[Reflection.Assembly]::LoadFile($tfsVersionControlClientAssembly) | Out-Null

$buildsDir = Join-Path -Path $curDir -ChildPath "Builds"
$outBaseDir = Join-Path -Path $buildsDir -ChildPath $tfsProjectName

if (Test-Path -Path $outBaseDir) {
    Remove-Item -Path $outBaseDir -Force -Recurse | Out-Null
}

mkdir -Force $outBaseDir | Out-Null
cd $buildsDir

"Removing existing workspace at $tfsCollectionUri if it exists..."
tf workspace /delete "AddPowerDelivery" /collection:"$tfsCollectionUri" | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "NOTE: Error above is normal. This occurs if there wasn't a mapped working folder already."
}

try {
    "Creating TFS workspace for $tfsCollectionUri..."
    tf workspace /new /noprompt "AddPowerDelivery" /collection:"$tfsCollectionUri"

    "Getting files from project $tfsProjectName..."
    tf get "$tfsProjectName\*" /recursive /overwrite /noprompt

    $templateDir = Join-Path -Path $curDir -ChildPath "Templates\$templateName"

    if (!(Test-Path -Path $templateDir)) {
        Write-Error "Template '$templateName' does not exist."
        exit
    }

    "$templateDir -> $outBaseDir"
    Copy-Item -Recurse -Path "$templateDir\*" -Destination $outBaseDir -Force | Out-Null
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerDeliveryEnvironment.csv") -Destination "$outBaseDir" -Force
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "BuildProcessTemplates") -Recurse -Destination "$outBaseDir" -Force
    Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerShellModules") -Recurse -Destination "$outBaseDir" -Force

    Move-Item -Path "$outBaseDir\Build.ps1" -Destination "$outBaseDir\$name.ps1" -Force
    Move-Item -Path "$outBaseDir\BuildLocalEnvironment.csv" -Destination "$outBaseDir\$($name)LocalEnvironment.csv" -Force
    Move-Item -Path "$outBaseDir\BuildCommitEnvironment.csv" -Destination "$outBaseDir\$($name)CommitEnvironment.csv" -Force
    Move-Item -Path "$outBaseDir\BuildTestEnvironment.csv" -Destination "$outBaseDir\$($name)TestEnvironment.csv" -Force
    Move-Item -Path "$outBaseDir\BuildCapacityTestEnvironment.csv" -Destination "$outBaseDir\$($name)CapacityTestEnvironment.csv" -Force
    Move-Item -Path "$outBaseDir\BuildProductionEnvironment.csv" -Destination "$outBaseDir\$($name)ProductionEnvironment.csv" -Force

    "Checking in changed or new files to source control..."
    tf add *.* /noprompt /recursive
    tf checkin /noprompt /recursive

    "Connecting to TFS server at $collectionUri to create builds..."

    $projectCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsCollectionUri)
    $buildServer = $projectCollection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])

    $buildDictionary = @{
        "$name - Commit" = "Commit";
        "$name - Test" = "Test";
        "$name - Demo" = "Demo";
        "$name - CapacityTest" = "CapacityTest";
        "$name - Production" = "Production";
    }

    $buildDictionary.GETENUMERATOR() | % {
        $buildName = $_.Key
        $buildEnv = $_.Value

        $build = $null

        try {
            $build = $buildServer.GetBuildDefinition($tfsProjectName, $buildName)
            "Found build $buildName, updating..."
        }
        catch {
            "Creating build $buildName..."
            
            $build = $buildServer.CreateBuildDefinition($tfsProjectName)
        }
            
        $build.Name = $buildName

        if ($buildName.EndsWith("Commit")) {
            $build.ContinuousIntegrationType = [Microsoft.TeamFoundation.Build.Client.ContinuousIntegrationType]::Individual
        }
        else {
            $build.ContinuousIntegrationType = [Microsoft.TeamFoundation.Build.Client.ContinuousIntegrationType]::None
        }

        $build.BuildController = $buildServer.GetBuildController($buildController)

        $buildFound = $false

        $processTemplatePath = "`$/$tfsProjectName/BuildProcessTemplates/PowerDeliveryTemplate.xaml"

        $processTemplates = $buildServer.QueryProcessTemplates($tfsProjectName)

        foreach ($processTemplate in $processTemplates) {
            if ($processTemplate.ServerPath -eq $processTemplatePath) {
                $build.Process = $processTemplate
                $buildFound = $true
                break
            }
        }

        if (!$buildFound) {

            "Creating build process template for $processTemplatePath..."
            $processTemplate = $buildServer.CreateProcessTemplate($tfsProjectName, $processTemplatePath)
            $processTemplate.TemplateType = [Microsoft.TeamFoundation.Build.Client.ProcessTemplateType]::Custom
            "Saving process template..."
            $processTemplate.Save()
            "Done"

            if ($processTemplate -eq $null) {
                throw "Couldn't find a process template at $processTemplatePath"
            }
            $build.Process = $processTemplate
        }

        $processParams = [Microsoft.TeamFoundation.Build.Workflow.WorkflowHelpers]::DeserializeProcessParameters($build.ProcessParameters)
        
        $processParams["Environment"] = $buildEnv
        
        $scriptPath = "`$/$tfsProjectName/$name.ps1"
        $processParams["PowerShell Script Path"] = $scriptPath
        
        $build.ProcessParameters = [Microsoft.TeamFoundation.Build.Workflow.WorkflowHelpers]::SerializeProcessParameters($processParams)

        $build.Save()
    }
    
    "Delivery pipeline '$name' ready at $tfsCollectionUri for project '$tfsProjectName'" 
}
finally {
    cd $curDir
    tf workspace /delete "AddPowerDelivery" /collection:"$tfsCollectionUri" | Out-Null
}