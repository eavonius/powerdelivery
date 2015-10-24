<# InstallLocal.ps1

Installs PowerDelivery3 and PowerDelivery3Node locally from source with chocolatey.

Used for development only.
#>

$ErrorActionPreference = 'Stop'

try {
  cpack
}
catch {
  "Error building nuget package - $_"
}

try {
  choco install powerdelivery3node -fdv -s $pwd
  choco install powerdelivery3 -fdv -s $pwd
}
catch {
  "Error installing chocolatey packages from source - $_"
}
