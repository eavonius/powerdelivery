<# ChocolateyInstall.ps1

Installs PowerDelivery3Node with chocolatey.
#>

$ErrorActionPreference = 'Stop'

#$moduleDir = Split-Path -parent $MyInvocation.MyCommand.Definition

Start-ChocolateyProcessAsAdmin -Statements {

    Write-Host "Test"

    #$moduleDir = Split-Path -parent $MyInvocation.MyCommand.Definition
    #Write-Host $moduleDir
}

# . (Join-Path $moduleDir 'chocolateyPowerDeliveryUtils.ps1'
# Install-PowerDeliveryModule -moduleDir $moduleDir -moduleName PowerDeliveryNode -packageId powerdelivery3node
