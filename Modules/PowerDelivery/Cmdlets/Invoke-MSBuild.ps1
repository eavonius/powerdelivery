<#
.Synopsis
Compiles a project using msbuild.exe.

.Description
The Invoke-MSBuild cmdlet is used to compile a MSBuild-compatible project or solution. You should always use this cmdlet instead of a direct call to msbuild.exe or existing cmdlets you may have found online when working with powerdelivery.

This cmdlet provides the following essential continuous delivery features:

Updates the version of any AssemblyInfo.cs (or AssemblyInfo.vb) files with the current build version. This causes all of your binaries to have the build number. For example, if your build pipeline's version in the script is set to 1.0.2 and this is a build against changeset C234, the version of your assemblies will be set to 1.0.2.234.

Automatically targets a build configuration matching the environment name ("Development", "Test", or "Production"). Create build configurations named "Development", "Test", and "Production" with appropriate settings in your projects for this to work. If you don't want this, you'll have to explicitly pass the configuration as a parameter.

Reports the status of the compilation back to TFS to be viewed in the build summary. This is important because it allows tests run using mstest.exe to have their run results associated with the compiled assets created using this cmdlet.

.Example
Invoke-MSBuild MyProject/MySolution.sln -properties  @{MyCustomProp = SomeValue}

.Parameter projectFile
A relative path at or below the script directory that specifies an MSBuild project or solution to compile.

.Parameter properties
Optional. A PowerShell hash containing name/value pairs to set as MSBuild properties.

.Parameter target
Optional. The name of the MSBuild target to invoke in the project file. Defaults to the default target specified within the project file.

.Parameter toolsVersion
Optional. The version of MSBuild to run ("2.0", "3.5", "4.0", etc.). The default is "4.0".

.Parameter verbosity
Optional. The verbosity of this MSBuild compilation. The default is "m".

.Parameter buildConfiguration
Optional. The default is to use the same as the environment name. Create build configurations named "Development", "Test", and "Production" with appropriate settings in your projects.

.Parameter flavor
Optional. The platform configuration (x86, x64 etc.) of this MSBuild complation. The default is "AnyCPU".

.Parameter ignoreProjectExtensions
Optional. A semicolon-delimited list of project extensions (".smproj;.csproj" etc.) of projects in the solution to not compile.
#>
function Invoke-MSBuild
{
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][string] $projectFile, 
    [Parameter(Position=1,Mandatory=0)] $properties = @{}, 
    [Parameter(Position=2,Mandatory=0)][string] $target, 
    [Parameter(Position=3,Mandatory=0)][string] $toolsVersion = '4.0', 
    [Parameter(Position=4,Mandatory=0)][string] $verbosity = "m", 
    [Parameter(Position=5,Mandatory=0)][string] $buildConfiguration, 
    [Parameter(Position=6,Mandatory=0)][string] $flavor = "AnyCPU", 
    [Parameter(Position=7,Mandatory=0)][string] $ignoreProjectExtensions
  )

  if ([String]::IsNullOrWhiteSpace($buildConfiguration))
  {
    if ($pow.EnvironmentName -eq 'Local')
    {
		  $buildConfiguration = 'Debug'
    }
    else
    {
      $buildConfiguration = 'Release'
    }

    if (!$properties.ContainsKey('Configuration'))
    {
      $properties.Add('Configuration', $buildConfiguration)
    }
  }
  else
  {
    $properties.Add('Configuration', $buildConfiguration)
  }

  $regKey = "HKLM:\Software\Microsoft\MSBuild\ToolsVersions\$toolsVersion"
  $regProperty = "MSBuildToolsPath"
  $regKeyProperty = $null

  try
  {
    $regKeyProperty = (Get-ItemProperty $regKey)
  }
  catch
  {
    Write-Host ".NET ToolsVersion $toolsVersion not found in the registry. Is this version not installed?"
    throw 
  }

  $msbuildExe = Join-Path -path $regKeyProperty.$regProperty -childpath "msbuild.exe"

  $msBuildCommand = """$msbuildExe"""
  $msBuildCommand += " /nologo /m"

  if ($properties.length -gt 0)
  {  
    $properties.Keys | % {
      $msBuildCommand += " ""/p:$($_)=$($properties.Item($_))"""
    }
  }
	
  if ([string]::IsNullOrWhiteSpace($toolsVersion) -eq $false)
  {
    $msBuildCommand += " ""/tv:$toolsVersion"""
  }

  $msBuildCommand += " `"/consoleloggerparameters:Verbosity=q`""

  if ([string]::IsNullOrWhiteSpace($verbosity) -eq $false)
  {
    $msBuildCommand += " /v:$verbosity"
  }

  if ([string]::IsNullOrWhiteSpace($ignoreProjectExtensions) -eq $false)
  {
      $msBuildCommand += " ""/ignore:$ignoreProjectExtensions"""
  }

	if (![string]::IsNullOrWhiteSpace($target))
  {
		$msBuildCommand += " ""/T:$target"""
	}

  $currentDirectory = Get-Location

  $shortPath = [IO.Path]::GetDirectoryName($projectFile)
  $fullPath = Join-Path $currentDirectory $shortPath
  $fullPathNormalized = [IO.Path]::GetFullPath($fullPath)

  $projectFileName = [IO.Path]::GetFileName($projectFile)
  $fullProjectFile = Join-Path $fullPathNormalized $projectFileName
  $projectFileBase = [IO.Path]::GetFileNameWithoutExtension($projectFileName)
  $logFile = Join-Path $fullPathNormalized "$($projectFileBase).log"

  $msBuildCommand += " ""/l:FileLogger,Microsoft.Build.Engine;logfile=$logFile"""
  $msBuildCommand += " ""$fullProjectFile"""

  #Update-AssemblyInfoFiles -path $shortPath

  Set-Location $fullPathNormalized

  Invoke-Expression "& $msBuildCommand" | Out-Null

  if ($lastexitcode -ne 0)
  {
    $errorMessage = "Invoke-MSBuild failed. Check your parameters or try again with verbose output." 

    if (![String]::IsNullOrWhitespace($logFile))
    {
      $errorMessage += " See $logFile for details."
    }
    
    throw $errorMessage
  }
}

Export-ModuleMember -Function Invoke-MSBuild