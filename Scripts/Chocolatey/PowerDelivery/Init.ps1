<# Init.ps1

Initializes PowerDelivery3 when loaded by chocolatey.
#>

param($installPath, $toolsPath, $package)

$modulePath = Join-Path $toolsPath PowerDelivery.psm1
Import-Module $modulePath -Force
