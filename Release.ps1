<# Release.ps1

Increments versions, creates nuget packages, 
commits changes, and pushes to chocolatey.
#>

$ErrorActionPreference = "Stop"

# Throw if lasterror not zero
#
function SafeInvoke($msg, $cmd) {
  Invoke-Command $cmd
  if ($lastexitcode -ne 0) {
    throw $msg
  }  
}

# Updates the PowerShell module version
#
function UpdateModuleVersion($manifestFile, $newVersion) {

  $content = Get-Content $manifestFile

  $newContent = $content -replace "^ModuleVersion = ['|`"].*['|`"]", "ModuleVersion = '$newVersion'"

  Out-File -FilePath $manifestFile -Force -InputObject $newContent
}

# Inserts file statments into a nuspec for a replacement token
#
function InsertNuspecFiles($content, $token, $path) {

  $files = Get-ChildItem -File "Modules\$path"
  
  $filesStatement = ""
  foreach ($file in $files) {
    $filesStatement += [Environment]::NewLine
    $filesStatement += "<file src=""Modules\$path\$file"" target=""tools\$path\$file"" />"
  }

  $content -replace $token, $filesStatement
}

# Generates a nuspec file using a template
#
function GenerateNuspec($module, $moduleId, $newVersion) {

  $template = "$moduleId.template.nuspec"
  $nuspec = "$moduleId.nuspec"

  $content = Get-Content $template

  $newContent = InsertNuspecFiles -Content $content -Token "{{ Cmdlets }}" -Path "$module\Cmdlets"
  $newContent = InsertNuspecFiles -Content $newContent -Token "{{ Templates }}" -Path "$module\Templates"

  Out-File -FilePath $nuspec -Force -InputObject $newContent

  [xml]$nuspecFile = Get-Content $nuspec

  $namespaces = New-Object Xml.XmlNamespaceManager $nuspecFile.NameTable
  $namespaces.AddNamespace('nu', 'http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd')

  $versionElement = $nuspecFile.SelectSingleNode('//nu:package/nu:metadata/nu:version', $namespaces)
  $versionElement.'#text' = "$newVersion"

  # Update the PowerDeliveryNode module dependency if PowerDelivery
  if ($module -eq 'PowerDelivery') {
    $nodeDependency = $nuspecFile.SelectSingleNode("//nu:package/nu:metadata/nu:dependencies/nu:dependency[@id='powerdelivery3node']", $namespaces)
    $nodeDependency.version = "$newVersion"
  }

  $nuspecFullPath = Join-Path (Get-Location) $nuspec
  $nuspecFile.Save($nuspecFullPath)

  SafeInvoke -msg "Error running cpack" -cmd { 
    choco pack "$nuspecFullPath"
  }
}

# Gets the new version for a release based on what's on chocolatey
#
function GetNewModuleVersion($moduleId) {
  $packages = $(clist powerdelivery3) -split [Environment]::NewLine
  foreach ($package in $packages) {
    if ($package.StartsWith("$moduleId ", [System.StringComparison]::InvariantCultureIgnoreCase)) {
      $latestVersion = New-Object System.Version -ArgumentList $package.Split(' ')[1]
      Write-Host "Latest version on chocolatey is $latestVersion"
      return "$($latestVersion.Major).$($latestVersion.Minor).$($latestVersion.Build + 1)"
    }
  }

  "3.0.0"
}

# Syncs changes with git
#
function Sync-Git($newVersion) {

  SafeInvoke -msg "Error adding changes to git" -cmd { 
    git add .
  }

  SafeInvoke -msg "Error committing changes to git" -cmd { 
    git commit --allow-empty -m "Chocolatey $newVersion release." 
  }

  SafeInvoke -msg "Error pushing changes to git" -cmd { 
    git push
  }
}

$startDir = Get-Location

try {
  del *.nupkg

  $modules = @{
    PowerDeliveryNode = "PowerDelivery3Node";
    PowerDelivery = "PowerDelivery3"
  }

  foreach ($module in $modules.GetEnumerator()) {
    $module = $module.Key
    $moduleId = $modules[$module]

    $newVersion = GetNewModuleVersion -moduleId $moduleId

    UpdateModuleVersion -manifestFile "Modules\$module\$module.psd1" -newVersion $newVersion
    GenerateNuspec -module $module -moduleId $moduleId -newVersion $newVersion

    $nuPkgFile = (gci "$moduleId.*.nupkg").Name

    SafeInvoke -msg "Error publishing to chocolatey" -cmd { 
      cpush $nuPkgFile
    }

    Write-Host "$moduleId successfully released as $newVersion!" -ForegroundColor Green
  }

  Sync-Git -newVersion $newVersion
}
finally {
  Set-Location $startDir
}