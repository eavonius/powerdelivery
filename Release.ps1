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

  $nuspecFullPath = Join-Path (Get-Location) $nuspec
  $nuspecFile.Save($nuspecFullPath)

  SafeInvoke -msg "Error running cpack" -cmd { 
    cpack "$nuspecFullPath"
  }
}

# Gets the new version for a release based on what's on chocolatey
#
function GetNewModuleVersion {
  $packages = $(clist powerdelivery3) -split [Environment]::NewLine
  if ($packages[0] -ne '0 packages found.') {
    foreach ($package in $packages) {
      if ($package.StartsWith("powerdelivery3 ")) {
        $latestVersion = New-Object System.Version -ArgumentList $package.Split(' ')[1]
        Write-Host "Latest version on chocolatey is $latestVersion"
        return "$($latestVersion.Major).$($latestVersion.Minor).$($latestVersion.Build + 1)"
      }
    }
  }
  else {
    "3.0.0"
  }
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

  $newVersion = GetNewModuleVersion

  $modules = @{
    PowerDelivery = "PowerDelivery3";
    PowerDeliveryNode = "PowerDelivery3Node"
  }

  foreach ($module in $modules.GetEnumerator()) {
    $module = $module.Key
    $moduleId = $modules[$module]

    UpdateModuleVersion -manifestFile "Modules\$module\$module.psd1" -newVersion $newVersion
    GenerateNuspec -module $module -moduleId $moduleId -newVersion $newVersion
  }

  Sync-Git -newVersion $newVersion

  cd ..\gh-pages
  
  $pageFile = Join-Path . "_layouts\page.html"
  $pageFileName = [System.IO.Path]::GetFileName($pageFile)
  
  $newPageFileContent = (Get-Content $pageFileName) -replace "^.*version.*", "        <div id=`"new-version`">version $newVersion</div>"
  Out-File -Encoding ascii -FilePath $pageFile -Force -InputObject $newPageFileContent

  Sync-Git

  cd ..\master
  
  <#  
  $nuPkgFile = (gci *.nupkg).Name
  
  "$nuPkgFile -> http://www.chocolately.org..."
  
  try {
    cpush $nuPkgFile
  }
  catch {
    throw "Error pushing new package to chocolatey - $_"
  }
  #>

  Write-Host "PowerDelivery3 successfully released as $newVersion!" -ForegroundColor Green
}
finally {
  Set-Location $startDir
}