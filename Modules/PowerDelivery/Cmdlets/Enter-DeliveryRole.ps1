function Enter-DeliveryRole {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=1)][scriptblock] $Up,
    [Parameter(Position=1, Mandatory=0)][scriptblock] $Down
  )
  $fullPath = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
  $roleName = [System.IO.Path]::GetFileName($fullPath)

  $pow.roles.Add($roleName, @($Up, $Down))
}

Set-Alias Delivery:Role Enter-DeliveryRole
Export-ModuleMember -Function Enter-DeliveryRole -Alias Delivery:Role