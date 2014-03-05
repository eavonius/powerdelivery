<#
.Synopsis
Updates the AssemblyInfo.cs/AssemblyInfo.vb files to include the build application version.

.Description
Updates the AssemblyInfo.cs/AssemblyInfo.vb files to include the build application version. 
When a delivery pipeline script uses the Pipeline function to declare a version, this function 
will update the version of assemblies to match that version with the changeset appended at the end.

NOTE: You do not need to call this method if using hte Invoke-MSBuild cmdlet to compile your code, 
and if all the AssemblyInfo files you want to change are at or below the path to that project. If 
this is the case, Invoke-MSBuild updates them automatically.

.Parameter path
The path to update the version of AssemblyInfo files under.

.Example
Update-AssemblyInfoFiles "MyPath\MyProject"
#>
function Update-AssemblyInfoFiles {
    [CmdletBinding()]
    param([Parameter(Position=0,Mandatory=1)][string] $path)

    $buildAppVersion = Get-BuildAppVersion
	$buildAssemblyVersion = Get-BuildAssemblyVersion
    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = "AssemblyVersion(""$buildAssemblyVersion"")"
    $fileVersion = "AssemblyFileVersion(""$buildAppVersion"")"
    
    Get-ChildItem -r -Path $path -filter AssemblyInfo.cs | % {
        $filename = $_.Directory.ToString() + '\' + $_.Name
		$powerdelivery.assemblyInfoFiles += ,$filename
        Exec -errorMessage "Unable to update file attributes on $filename" { 
            attrib -r "$filename"
		}

		Write-Host "Updating $filename to AssemblyVersion: $assemblyVersion FileVersion: $fileVersion" 

        (Get-Content $filename) | % {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $fileVersionPattern, $fileVersion }
        } | Set-Content $filename
    }
}