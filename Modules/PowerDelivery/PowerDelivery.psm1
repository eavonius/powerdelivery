<#
PowerDelivery.psm1

powerdelivery - http://eavonius.github.com/powerdelivery

PowerShell module that enables writing build scripts that follow continuous delivery 
principles and deploy product assets into multiple environments.
#>

# Load cmdlets
$cmdletsDir = (Join-Path $PSScriptRoot "Cmdlets")
gci $cmdletsDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $cmdletsDir $_.Name) }

$env:TERM = "msys"

$script:pow = @{}
$pow.scriptDir = Split-Path $MyInvocation.MyCommand.Path