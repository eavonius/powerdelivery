# NewProject.ps1
#
# Creates a new project from one of the templates and adds it to TFS.

Param (
    [string]
    $name,
    [string]
    $templateName = 'Blank',
    [string]
    $tfsCollectionUri,
    [string]
    $tfsProjectName,
    [string]
    $vsVersion = '10.0'
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

$outBaseDir = Join-Path -Path $curDir -ChildPath $name

if (!(Test-Path -Path (Join-Path -Path $curDir -ChildPath $templateName))) {
    Write-Error "Template '$templateName' does not exist."
    exit
}

New-Item -ItemType Directory -Path $outBaseDir | Out-Null
Copy-Item -Path $templateName -Destination $outBaseDir | Out-Null

"Done"