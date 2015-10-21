# ChocolateyUninstall.ps1
#
# Uninstalls PowerDelivery 3 with chocolatey.
#
try {
  Remove-Module PowerDelivery | Out-Null
  Update-SessionEnvironment
}
catch {
}