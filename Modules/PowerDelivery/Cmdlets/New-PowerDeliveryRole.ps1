function New-PowerDeliveryRole {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=1)][scriptblock] $block
  )
  $fullPath = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
  $roleName = [System.IO.Path]::GetFileName($fullPath)
  $pow["$($roleName)Role"] = $block
}

Set-Alias pow:Role New-PowerDeliveryRole
Export-ModuleMember -Function New-PowerDeliveryRole -Alias pow:Role