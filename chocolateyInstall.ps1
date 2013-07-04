try { 
    $powerdeliveryDir = Split-Path -parent $MyInvocation.MyCommand.Definition
  
    Write-Host "Updating PSModulePath to include $powerdeliveryDir"

    $psModulePath = $env:PSModulePath
  
    $newEnvVar = $powerdeliveryDir

    $caseInsensitive = [StringComparison]::InvariantCultureIgnoreCase

    $pathSegment = "chocolatey\lib\powerdelivery"

    if (![String]::IsNullOrWhiteSpace($psModulePath)) {
        if (!$psModulePath.ToLower().Contains($pathSegment.ToLower())) {
            $newEnvVar = "$psModulePath;$powerdeliveryDir"
        }
        else {
            $indexOfSegment = $psModulePath.IndexOf($pathSegment, $caseInsensitive)
            $startingSemicolon = $psModulePath.LastIndexOf(";", $indexOfSegment, $caseInsensitive)
            $trailingSemicolon = $psModulePath.IndexOf(";", $indexOfSegment + $pathSegment.Length, $caseInsensitive)

            Write-Host "$indexOfSegment $startingSemicolon $trailingSemicolon"

            if ($startingSemicolon -ne -1) {
                $psModulePrefix = $psModulePath.Substring(0, $startingSemicolon)
                $newEnvVar = "$psModulePrefix;$powerdeliveryDir"
                if ($trailingSemicolon -ne -1) {
                    $newEnvVar += "$($psModulePath.Substring($trailingSemicolon))"
                }
            }
        }
    }

    "Setting environment var to $newEnvVar"

    [Environment]::SetEnvironmentVariable("PSModulePath", $newEnvVar, "Machine")

    "Powerdelivery is now ready."
  
    Write-ChocolateySuccess 'powerdelivery'
} 
catch {
    Write-ChocolateyFailure 'powerdelivery' "$($_.Exception.Message)"
    throw 
}