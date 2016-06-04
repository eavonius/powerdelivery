<# ChocolateyUninstall.ps1

Uninstalls PowerDelivery3 with chocolatey.
#>

$ErrorActionPreference = 'Stop'

$moduleDir = Split-Path -parent $MyInvocation.MyCommand.Definition

. (Join-Path $moduleDir 'chocolateyPowerDeliveryUtils.ps1')

Uninstall-PowerDeliveryModule -moduleDir $moduleDir -moduleName PowerDelivery -packageId powerdelivery3
