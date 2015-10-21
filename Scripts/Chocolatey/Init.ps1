# Init.ps1
#
# Initializes PowerDelivery 3 when loaded by chocolatey.
#
param($installPath, $toolsPath, $package)

$powerdeliveryModule = Join-Path $toolsPath PowerDelivery.psm1
Import-Module $powerdeliveryModule -Force
