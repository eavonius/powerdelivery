<# chocolateyPowerDeliveryUtils.ps1

Installs and Uninstalls PowerShell modules for PowerDelivery with chocolatey.
#>

$ErrorActionPreference = 'Stop'

function Install-PowerDeliveryModule {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=1)][string] $moduleDir,
    [Parameter(Position=1, Mandatory=1)][string] $moduleName,
    [Parameter(Position=2, Mandatory=1)][string] $packageId
  )
  
  $moduleDir = "$moduleDir\"

  $psModulePath = [Environment]::GetEnvironmentVariable("PSMODULEPATH", [EnvironmentVariableTarget]::Machine)

  $newEnvVar = $moduleDir

  $caseInsensitive = [StringComparison]::InvariantCultureIgnoreCase

  $pathSegment = "chocolatey\lib\$packageId\"

  if (![String]::IsNullOrWhiteSpace($psModulePath)) {
    if ($psModulePath.IndexOf($pathSegment, $caseInsensitive) -lt 0) { # First time installing
        if ($psModulePath.EndsWith(";")) {
            $psModulePath = $psModulePath.TrimEnd(";")
        }
        $newEnvVar = "$($psModulePath);$($moduleDir)"
    }
    else { # Replacing an existing install
        $indexOfSegment = $psModulePath.IndexOf($pathSegment, $caseInsensitive)
        $startingSemicolon = $psModulePath.LastIndexOf(";", $indexOfSegment, $caseInsensitive)
        $trailingSemicolon = $psModulePath.IndexOf(";", $indexOfSegment + $pathSegment.Length, $caseInsensitive)

        if ($startingSemicolon -ne -1) {
            $psModulePrefix = $psModulePath.Substring(0, $startingSemicolon)
            $newEnvVar = "$($psModulePrefix);$($moduleDir)"
        }     
        if ($trailingSemicolon -ne -1) {
            $newEnvVar += $psModulePath.Substring($trailingSemicolon)
        }
    }
  }
  else {
    $newEnvVar = "%PSMODULEPATH%;$newEnvVar"
  }

  [Environment]::SetEnvironmentVariable("PSMODULEPATH", $newEnvVar, [EnvironmentVariableTarget]::Machine)
  $Env:PSMODULEPATH = $newEnvVar

  Import-Module $moduleName -Force
}

function Uninstall-PowerDeliveryModule {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=1)][string] $moduleDir,
    [Parameter(Position=1, Mandatory=1)][string] $moduleName,
    [Parameter(Position=2, Mandatory=1)][string] $packageId
  )

  try {
    Remove-Module $moduleName | Out-Null
  }
  catch {}

  $moduleDir = "$moduleDir\"

  $psModulePath = [Environment]::GetEnvironmentVariable("PSMODULEPATH", [EnvironmentVariableTarget]::Machine)

  $newEnvVar = $moduleDir

  $caseInsensitive = [StringComparison]::InvariantCultureIgnoreCase

  $pathSegment = "chocolatey\lib\$packageId\"

  if (![String]::IsNullOrWhiteSpace($psModulePath)) {
    if ($psModulePath.IndexOf($pathSegment, $caseInsensitive) -ge 0) {
        $indexOfSegment = $psModulePath.IndexOf($pathSegment, $caseInsensitive)
        $startingSemicolon = $psModulePath.LastIndexOf(";", $indexOfSegment, $caseInsensitive)
        $trailingSemicolon = $psModulePath.IndexOf(";", $indexOfSegment + $pathSegment.Length, $caseInsensitive)

        if ($startingSemicolon -ne -1) {
            $newEnvVar = $psModulePath.Substring(0, $startingSemicolon)
        }     
        if ($trailingSemicolon -ne -1) {
            $newEnvVar += $psModulePath.Substring($trailingSemicolon)
        }

        [Environment]::SetEnvironmentVariable("PSMODULEPATH", $newEnvVar, [EnvironmentVariableTarget]::Machine)
        $Env:PSMODULEPATH = $newEnvVar
    }
  }
}
