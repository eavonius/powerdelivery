# Release.ps1
#
# Packages up a release, commits changes to git, and pushes to chocolatey.

function Update-ModuleVersion($file) {
  $fileName = [System.IO.Path]::GetFileName($file)
  Write-Host "$fileName -> $newVersion..."
  $newManifestContent = ((Get-Content $file) -replace "^ModuleVersion = ['|`"].*['|`"]", "ModuleVersion = '$newVersion'")
  Out-File -FilePath $file -Force -InputObject $newManifestContent
}

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
$originalDirectory = Get-Location

"-----------------------------------------"
"Releasing new version of powerdelivery..."
"-----------------------------------------"

del *.nupkg

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

$oldVersion = $latestVersion -join '.'
$latestVersion[$latestVersion.Length-1] = $(([int]$latestVersion[$latestVersion.Length-1]) + 1)
$script:newVersion = $latestVersion -join '.'

"Lastest version on chocolatey is $oldVersion"

$nuspecFullPath = Join-Path (Get-Location) .\PowerDelivery3.nuspec

[xml]$nuspecFile = Get-Content $nuspecFullPath

$namespaces = New-Object Xml.XmlNamespaceManager $nuspecFile.NameTable
$namespaces.AddNamespace('nu', 'http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd')

$versionElement = $nuspecFile.SelectSingleNode('//nu:package/nu:metadata/nu:version', $namespaces)

"Updating .nuspec to $newVersion..."

$versionElement.'#text' = "$newVersion"

$nuspecFile.Save($nuspecFullPath)

Update-ModuleVersion -file (Join-Path (Get-Location) .\Modules\PowerDelivery\PowerDelivery.psd1)

try {
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
}
finally {
  Set-Location $originalDirectory
}

"Powerdelivery successfully released as $newVersion!"