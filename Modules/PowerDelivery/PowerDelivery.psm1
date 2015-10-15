<#
PowerDelivery.psm1

powerdelivery - http://eavonius.github.com/powerdelivery

PowerShell module that enables writing build scripts that follow continuous delivery 
principles and deploy product assets into multiple environments.
#>

$env:TERM = "msys"

$script:pow = @{}
$pow.product = "PowerDelivery"
$pow.scriptDir = Split-Path $MyInvocation.MyCommand.Path

# Load internal scripts
$pow.internalDir = (Join-Path $pow.scriptDir "internal")
gci $pow.internalDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $pow.internalDir $_.Name) }

# Check PowerShell version >= 3 or <= 5
$pow.hostMajorVersion = $PSVersionTable.PSVersion.Major
if ($pow.hostMajorVersion -lt 3 -or ($pow.hostMajorVersion -gt 5))
{
  throw "PowerDelivery requires Windows PowerShell 3 to 5."
}

# Set defaults
$pow.colors = @{
  SuccessForeground = 'Green'; 
  FailureForeground = 'Red'; 
  StepForeground = 'Magenta'; 
  RoleForeground = 'Yellow';
  CommandForeground = 'White'; 
  LogFileForeground = 'White' 
}

if (Get-Module powerdelivery)
{
    $pow.version = Get-Module powerdelivery | select version | ForEach-Object { $_.Version.ToString() }
}
else
{
    $pow.version = "SOURCE"
}

# Load cmdlets
$pow.cmdletsDir = (Join-Path $pow.scriptDir "cmdlets")
gci $pow.cmdletsDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $pow.cmdletsDir $_.Name) }

if (!(TestAdministrator)) {
    throw "Please run PowerDelivery using an elevated (Administrative) command prompt."
}