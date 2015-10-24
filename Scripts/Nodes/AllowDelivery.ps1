<# AllowDelivery.ps1

Allows powerdelivery to deploy to the node that this script is 
executed on. Must be run in a PowerShell Administrator console.

http://www.powerdelivery.io/environments.html#enabling_deployment_to_nodes
#>
param(
  [Parameter(Position=0,Mandatory=0)][switch] $AllowAnyPublicAddress
)

winrm quickconfig -Force
Enable-WSManCredSSP -Role Server -Force | Out-Null
Enable-PSRemoting -Force -SkipNetworkProfileCheck

if ($AllowPublicAnyAddress) {

  # This will allow PowerShell to connect from non-domain computers if necessary. 
  # Without it, this computer will only allow connections when the user running 
  # powerdelivery is on the same subnet.
  Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
}

Write-Host "Powerdelivery has been permitted to deploy to this computer."
