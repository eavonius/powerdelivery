function Update-AssemblyInfoFiles {
    [CmdletBinding()]
    param([Parameter(Mandatory=1)][string] $path)

	if ($environment -eq 'Development' -or $environment -eq 'Commit') {
        $buildAppVersion = Get-BuildAppVersion
	    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	    $assemblyVersion = "AssemblyVersion(""$buildAppVersion"")"
	    $fileVersion = "AssemblyFileVersion(""$buildAppVersion"")"
	    
	    Get-ChildItem -r -Path $path -filter AssemblyInfo.cs | ForEach-Object {
	        $filename = $_.Directory.ToString() + '\' + $_.Name
			$powerdelivery.assemblyInfoFiles += ,$filename
	        $filename + " -> $appVersion.$changeSetNumber"
	        Exec -errorMessage "Unable to update file attributes on $filename" { 
                attrib -r "$filename"
			}
	        (Get-Content $filename) | ForEach-Object {
	            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
	            % {$_ -replace $fileVersionPattern, $fileVersion }
	        } | Set-Content $filename
	    }
		return $buildAppVersion
	}
	return ""
}