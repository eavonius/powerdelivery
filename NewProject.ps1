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
    $vsVersion = "10.0"
)

Write-Host
"New Project Generation Utility"
Write-Host
"powerdelivery - http://github.com/eavonius/powerdelivery"
Write-Host

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

$vsInstallDir = Get-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\VisualStudio\$($vsVersion)_Config" -Name InstallDir       
if ([string]::IsNullOrWhiteSpace($vsInstallDir)) {
    throw "No version of Visual Studio with the same tools as your version of TFS is installed on the build server."
}
else {
    $ENV:Path += ";$($vsInstallDir.InstallDir)"
}

$refAssemblies = "ReferenceAssemblies\v2.0"
$tfsClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Client.dll"
$tfsBuildClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.Build.Client.dll"
$tfsVersionControlClientAssembly = Join-Path -Path $vsInstallDir.InstallDir -ChildPath "$refAssemblies\Microsoft.TeamFoundation.VersionControl.Client.dll"

[Reflection.Assembly]::LoadFile($tfsClientAssembly) | Out-Null
[Reflection.Assembly]::LoadFile($tfsBuildClientAssembly) | Out-Null
[Reflection.Assembly]::LoadFile($tfsVersionControlClientAssembly) | Out-Null

$curDir = Get-Location
$buildsDir = Join-Path -Path $curDir -ChildPath "Builds"
$outBaseDir = Join-Path -Path $buildsDir -ChildPath $name
$templateDir = Join-Path -Path $curDir -ChildPath "Templates\$templateName"

if (!(Test-Path -Path $templateDir)) {
    Write-Error "Template '$templateName' does not exist."
    exit
}

Remove-Item -Path $outBaseDir -Force -Recurse | Out-Null
New-Item -ItemType Directory -Path $outBaseDir -Force | Out-Null
Copy-Item -Recurse -Path "$templateDir\*" -Destination $outBaseDir -Force | Out-Null
Move-Item -Path "$outBaseDir\Build.ps1" -Destination "$outBaseDir\$name.ps1" -Force
Move-Item -Path "$outBaseDir\BuildLocalEnvironment.csv" -Destination "$outBaseDir\$($name)LocalEnvironment.csv" -Force
Move-Item -Path "$outBaseDir\BuildCommitEnvironment.csv" -Destination "$outBaseDir\$($name)CommitEnvironment.csv" -Force
Move-Item -Path "$outBaseDir\BuildTestEnvironment.csv" -Destination "$outBaseDir\$($name)TestEnvironment.csv" -Force
Move-Item -Path "$outBaseDir\BuildCapacityTestEnvironment.csv" -Destination "$outBaseDir\$($name)CapacityTestEnvironment.csv" -Force
Move-Item -Path "$outBaseDir\BuildProductionEnvironment.csv" -Destination "$outBaseDir\$($name)ProductionEnvironment.csv" -Force
Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerDeliveryEnvironment.csv") -Destination "$outBaseDir" -Force
Copy-Item -Path (Join-Path -Path $curDir -ChildPath "BuildProcessTemplates") -Recurse -Destination "$outBaseDir" -Force
Copy-Item -Path (Join-Path -Path $curDir -ChildPath "PowerShellModules") -Recurse -Destination "$outBaseDir" -Force

Remove-Item -Path $outBaseDir -Force -Recurse | Out-Null

"Done"