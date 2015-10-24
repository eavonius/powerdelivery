<# PowerDeliveryNode.psm1

Script for PowerShell module.

http://www.powerdelivery.io
#>

# Load cmdlets
$cmdletsDir = (Join-Path $PSScriptRoot "Cmdlets")
gci $cmdletsDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $cmdletsDir $_.Name) }
