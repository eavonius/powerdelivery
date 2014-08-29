$ErrorActionPreference = "Stop"
$originalDirectory = Get-Location

# Releases the PowerDelivery Visual Studio extension for a specific version 
# of Visual Studio to chocolatey.org. This script is meant to be included 
# and called from a release script within an extension project folder.
#
function Release-Extension($extensionVersion) {

    $packageName = "PowerDelivery-VSExtension-$extensionVersion"
    $projectFile = "PowerDeliveryVSExtension.$($extensionVersion).csproj"
    $nuspecFile = "PowerDelivery-VSExtension-$($extensionVersion).nuspec"

    # Updates the .vsix file version to match the chocolatey release
    #
    function Update-Vsix {

        "Updating VSIX manifest to $newVersion..."
        
        $vsixManifestPath = Join-Path $currentDirectory .\source.extension.vsixManifest
        
        [xml]$vsixFile = Get-Content $vsixManifestPath
        $vsixNs = New-Object Xml.XmlNamespaceManager $vsixFile.NameTable
        
        if ($extensionVersion -lt 2013) {
            $vsixNs.AddNamespace('vs', 'http://schemas.microsoft.com/developer/vsx-schema/2010')
            $versionElement = $vsixFile.SelectSingleNode('//vs:Vsix/vs:Identifier/vs:Version', $vsixNs)
            $versionElement.'#text' = "$newVersion"
        }
        else {
            $vsixNs.AddNamespace('vs', 'http://schemas.microsoft.com/developer/vsx-schema/2011')
            $identityElement = $vsixFile.SelectSingleNode('//vs:PackageManifest/vs:Metadata/vs:Identity', $vsixNs)
            $identityElement.Version = "$newVersion"
        }
        
        $vsixFile.Save($vsixManifestPath)
    }

    # Builds the source code for the extension
    #
    function Build-Source {

        msbuild "$projectFile" "/consoleloggerparameters:Verbosity=q" /p:Configuration=Release /nologo
        
        if ($LASTEXITCODE -ne 0) {
            throw "MSBuild compilation failed. Last exit code was $LASTEXITCODE"
        }
    }

    # Updates the assembly version to match the release version
    #
    function Update-AssemblyInfo {

        "Updating AssemblyInfo.cs to $newVersion..."
        
        $filename = Join-Path $currentDirectory .\Properties\AssemblyInfo.cs
        
        $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $assemblyVersion = "AssemblyVersion(""$newVersion"")"
        $fileVersion = "AssemblyFileVersion(""$newVersion"")"
        
        (Get-Content $filename) | % {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $fileVersionPattern, $fileVersion }
        } | Set-Content $filename
    }

    # Updates the NuGet version to match the chocolatey version
    #
    function Update-Nuspec {

        $script:nuspecFullPath = Join-Path $currentDirectory ".\$($nuspecFile)"

        [xml]$nuspecFile = Get-Content $nuspecFullPath

        $namespaces = New-Object Xml.XmlNamespaceManager $nuspecFile.NameTable
        $namespaces.AddNamespace('nu', 'http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd')

        $versionElement = $nuspecFile.SelectSingleNode('//nu:package/nu:metadata/nu:version', $namespaces)

        "Updating .nuspec to $newVersion..."

        $versionElement.'#text' = "$newVersion"

        $nuspecFile.Save($nuspecFullPath)
    }

    # Packages the release for chocolatey.org
    #
    function Package-Chocolatey {

        "$nuspecFullPath -> $($packageName).$($newVersion).nupkg"

        Exec -errorMessage "Error creating .nupkg" -ErrorAction Stop {
            cpack "$nuspecFullPath"
        }
    }

    # Pushes the release to chocolatey.org
    function Push-Chocolatey {

        $nuPkgFile = (gci *.nupkg).Name

        "$nuPkgFile -> http://www.chocolately.org..."

        Exec -errorMessage "Error pushing new package to chocolatey" -ErrorAction Stop {
            cpush $nuPkgFile
        }
    }

    "----------------------------------------------------------"
    "Releasing new version of $packageName..."
    "----------------------------------------------------------"

    del *.nupkg

    $latestVersionMessage = $(clist $packageName)

    $script:currentDirectory = Get-Location

    if ($latestVersionMessage.Trim() -eq "No packages found.") {
        $latestVersion = "1.0.0"
        $script:newVersion = "1.0.0"
    }
    else {

        $latestVersion = ""

        if ($latestVersionMessage.GetType().Name -eq "Object[]") {
            $latestVersionMessage | ForEach-Object {
                if ($_.StartsWith("$packageName ", [StringComparison]::CurrentCultureIgnoreCase)) {
                    $latestVersion = $_.split(' ')[1].split('.')
                }
            }
        }
        else {
            $latestVersion = $latestVersionMessage.split(' ')[1].split('.')  
        }

        $oldVersion = $latestVersion -join '.'

        $latestVersion[$latestVersion.Length-1] = $(([int]$latestVersion[$latestVersion.Length-1]) + 1)
        $script:newVersion = $latestVersion -join '.'

        "Lastest version on chocolatey is $oldVersion"

        Update-Nuspec
        Update-AssemblyInfo
        Update-Vsix
    }

    Build-Source
    Package-Chocolatey
    Push-Chocolatey
}