function New-DeliveryRole {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=1)][scriptblock] $block
  )
  $fullPath = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
  $roleName = [System.IO.Path]::GetFileName($fullPath)
  $pow["$($roleName)Role"] = $block
}

Set-Alias Delivery:Role New-DeliveryRole
Export-ModuleMember -Function New-DeliveryRole -Alias Delivery:Role