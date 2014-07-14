# release.ps1
#
# Packages up a release, commits changes to git, and pushes to chocolatey.
#

. .\PowerDelivery\Exec.ps1

function Update-ModuleVersion($file) {
	$fileName = [System.IO.Path]::GetFileName($file)
	"$fileName -> $newVersion..."
	$newManifestContent = ((Get-Content $file) -replace "^ModuleVersion = ['|`"].*['|`"]", "ModuleVersion = '$newVersion'")
	Out-File -FilePath $file -Force -InputObject $newManifestContent
}

function Sync-Git {

	Exec -errorMessage "Error adding changes to git" -ErrorAction Stop {
		git add .
	}
	Exec -errorMessage "Error committing changes to git" -ErrorAction Stop {
		git commit --allow-empty -m "Chocolatey $newVersion release."
	}
	Exec -errorMessage "Error pushing changes to git" -ErrorAction Stop {
		git push
	}
}

$ErrorActionPreference = "Stop"
$originalDirectory = Get-Location

"-----------------------------------------"
"Releasing new version of powerdelivery..."
"-----------------------------------------"

del *.nupkg

$listCommand = $(clist powerdelivery)

$latestVersion = ""

if ($listCommand.GetType().Name -eq "Object[]") {
	$listCommand | ForEach-Object {
		if ($_.StartsWith("PowerDelivery ")) {
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

$nuspecFullPath = Join-Path (Get-Location) .\PowerDelivery.nuspec

[xml]$nuspecFile = Get-Content $nuspecFullPath

$namespaces = New-Object Xml.XmlNamespaceManager $nuspecFile.NameTable
$namespaces.AddNamespace('nu', 'http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd')

$versionElement = $nuspecFile.SelectSingleNode('//nu:package/nu:metadata/nu:version', $namespaces)

"Updating .nuspec to $newVersion..."

$versionElement.'#text' = "$newVersion"

$nuspecFile.Save($nuspecFullPath)

Update-ModuleVersion -file (Join-Path (Get-Location) .\PowerDelivery\PowerDelivery.psd1)

Get-ChildItem -Path "*Module\*.psd1" | ForEach-Object {
	Update-ModuleVersion -file $_
}

try {

	Sync-Git

	cd ..\gh-pages
	
	$indexFile = Join-Path . .\index.html
	$indexFileName = [System.IO.Path]::GetFileName($indexFile)
	"$indexFileName -> $newVersion..."
	$newIndexFileContent = (Get-Content $indexFileName) -replace "^.*Version.*", "`t`t<span class=`"label label-info`">Version $newVersion</span>"
	Out-File -Encoding ascii -FilePath $indexFile -Force -InputObject $newIndexFileContent

	Sync-Git

	cd ..\master
	
	"$nuspecFullPath -> PowerDelivery.$($newVersion).nupkg"
	
	Exec -errorMessage "Error creating .nupkg" -ErrorAction Stop {
		cpack "$nuspecFullPath"
	}
	
	$nuPkgFile = (gci *.nupkg).Name
	
	"$nuPkgFile -> http://www.chocolately.org..."
	
	Exec -errorMessage "Error pushing new package to chocolatey" -ErrorAction Stop {
		cpush $nuPkgFile
	}
}
finally {
	Set-Location $originalDirectory
}

"Powerdelivery successfully released as $newVersion!"