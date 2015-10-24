<# Init.ps1

Initializes PowerDelivery3Node when loaded by chocolatey.
#>

param($installPath, $toolsPath, $package)

$modulePath = Join-Path $toolsPath PowerDeliveryNode.psm1
Import-Module $modulePath -Force
