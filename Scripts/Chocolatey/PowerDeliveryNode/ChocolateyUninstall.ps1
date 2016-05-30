<# ChocolateyUninstall.ps1

Uninstalls PowerDelivery3Node with chocolatey.
#>

try {
  Remove-Module PowerDeliveryNode | Out-Null
  Update-SessionEnvironment -Full
}
catch {}
