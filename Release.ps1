<# Release.ps1

Increments versions, creates nuget packages, 
commits changes, and pushes to chocolatey.
#>

# Updates the PowerShell module version
#
function UpdateModuleVersion($manifestFile, $newVersion) {

  $content = Get-Content $manifestFile

  $newContent = $content -replace "^ModuleVersion = ['|`"].*['|`"]", "ModuleVersion = '$newVersion'")

  Out-File -FilePath $manifestFile -Force -InputObject $newContent
}

# Inserts file statments into a nuspec for a replacement token
#
function InsertNuspecFiles($content, $token, $path) {

  $files = Get-ChildItem -File "Modules\$path"
  
  $filesStatement = ""
  foreach ($file in $files) {
    $filesStatement += [Environment]::NewLine
    $filesStatement += "<file src=""Modules\$path\$cmdlet"" target=""tools\$path\$cmdlet"" />"
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

  $nuspecFullPath = Join-Path (Get-Location) $nuspec
  $nuspecFile.Save($nuspecFullPath)
}

# Gets the new version for a release based on what's on chocolatey
#
function GetNewModuleVersion {
  $listCommand = $(clist powerdelivery3)

  $latestVersion = ""

  if ($listCommand.GetType().Name -eq "Object[]") {
    $listCommand | ForEach-Object {
      if ($_.StartsWith("PowerDelivery3 ")) {
        $latestVersion = $_.split(' ')[1].split('.')
      }
    }
  }
  else {
    $latestVersion = $listCommand.split(' ')[1].split('.')  
  }

  if ([String]::IsNullOrEmpty($latestVersion)) {
    $latestVersion = "3.0.0"
  }

  $oldVersion = $latestVersion -join '.'
  $latestVersion[$latestVersion.Length-1] = $(([int]$latestVersion[$latestVersion.Length-1]) + 1)
  $latestVersion -join '.'
}

# Syncs changes with git
#
function Sync-Git {
  try {
    git add .
  }
  catch {
    throw "Error adding changes to git - $_"
  }

  try {
    git commit --allow-empty -m "Chocolatey $newVersion release."
  }
  catch {
    throw "Error committing changes to git - $_"
  }

  try {
    git push
  }
  catch {
    throw "Error pushing changes to git - $_"
  }
}

$ErrorActionPreference = "Stop"

$startDir = Get-Location

Write-Host "------------------------------------------"
Write-Host "Releasing new version of powerdelivery3..."
Write-Host "------------------------------------------"

del *.nupkg

$newVersion = GetNewModuleVersion

$modules = @{
  PowerDelivery = "PowerDelivery3";
  PowerDeliveryNode = "PowerDelivery3Node"
}

foreach ($module in $modules.GetEnumerator()) {
  $module = $module.Key
  $moduleId = $module.Value
  UpdateModuleVersion -manifestFile "Modules\$moduleDir\$moduleDir.psd1" -newVersion $newVersion
  GenerateNuspec -module $module -moduleId $moduleId -newVersion $newVersion
}

try {
  <#
  Sync-Git

  cd ..\gh-pages
  
  $pageFile = Join-Path . .\_layouts\page.html
  $pageFileName = [System.IO.Path]::GetFileName($pageFile)
  
  Write-Host "$pageFileName -> $newVersion..."

  $newPageFileContent = (Get-Content $pageFileName) -replace "^.*version.*", "        <div id=`"new-version`">version $newVersion</div>"
  Out-File -Encoding ascii -FilePath $pageFile -Force -InputObject $newPageFileContent

  Sync-Git

  cd ..\master
  
  Write-Host "$nuspecFullPath -> PowerDelivery.$($newVersion).nupkg"
  
  try {
    cpack "$nuspecFullPath"
  }
  catch {
    throw "Error creating .nupkg - $_"
  }
  
  $nuPkgFile = (gci *.nupkg).Name
  
  "$nuPkgFile -> http://www.chocolately.org..."
  
  try {
    cpush $nuPkgFile
  }
  catch {
    throw "Error pushing new package to chocolatey - $_"
  }
  #>
}
finally {
  Set-Location $startDir
}

Write-Host "PowerDelivery3 successfully released as $newVersion!" -ForegroundColor Green