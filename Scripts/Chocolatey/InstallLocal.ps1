# InstallLocal.ps1
#
# Installs PowerDelivery 3 locally from source with chocolatey.
#
# Used for development only.
#
$ErrorActionPreference = 'Stop'

try {
  cpack
}
catch {
  "Error building nuget package - $_"
}

try {
  choco install powerdelivery3 -fdv -s $pwd
}
catch {
  "Error installing chocolatey package from source - $_"
}
