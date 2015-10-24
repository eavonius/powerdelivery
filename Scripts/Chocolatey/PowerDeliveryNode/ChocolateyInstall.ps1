<# ChocolateyInstall.ps1

Installs PowerDelivery3Node with chocolatey.
#>

$ErrorActionPreference 'Stop'

$moduleDir = Split-Path -parent $MyInvocation.MyCommand.Definition

Write-Host "Updating PSModulePath to include $moduleDir..."

$psModulePath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath).PSModulePath

$newEnvVar = $moduleDir

$caseInsensitive = [StringComparison]::InvariantCultureIgnoreCase

$pathSegment = "chocolatey\lib\powerdeliverynode"

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

Write-Host "Updating PSMODULEPATH in registry to include $moduleDir..."

Start-ChocolateyProcessAsAdmin @"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'PSModulePath' -Value '$newEnvVar'
"@

Write-Host "Updating PSMODULEPATH in current session to include $moduleDir..."

[Environment]::SetEnvironmentVariable("PSMODULEPATH", $newEnvVar, [EnvironmentVariableTarget]::Machine)

$Env:PSMODULEPATH = "$newEnvVar"

Update-SessionEnvironment

[Environment]::SetEnvironmentVariable("PSMODULEPATH", $newEnvVar, [EnvironmentVariableTarget]::Machine)

$Env:PSMODULEPATH = "$newEnvVar"

Write-Host "Forcing import of new version of PowerDeliveryNode module into current session..."

Import-Module PowerDeliveryNode -Force
