<# 
Allows powerdelivery to deploy to the node that 
this script is executed on. Must be run in a 
PowerShell Administrator console.
#>
param(
  [Parameter(Position=0,Mandatory=0)][switch] $AllowAnyPublicAddress
)

winrm quickconfig -Force
Enable-WSManCredSSP -Role Server -Force | Out-Null
Enable-PSRemoting -Force -SkipNetworkProfileCheck

if ($AllowPublicAnyAddress) {

  # This will open up PowerShell to connect using non-domain computers if necessary. 
  # If you don't set this, the remote computer will only allow connections when 
  # they are on the same subnet.
  Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
}

Write-Host "Powerdelivery has been permitted to deploy to this computer."
