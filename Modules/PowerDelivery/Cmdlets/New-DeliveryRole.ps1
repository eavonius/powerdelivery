function New-DeliveryRole {
  param(
    [Parameter(Position=1,Mandatory=1)][string] $RoleName
  )

  $templatesPath = Join-Path $pow.scriptDir "Templates"

  $roleDir = ".\Roles\$RoleName"

  if (Test-Path $roleDir) {
    throw "Directory $roleDir already exists."
  }

  New-Item $roleDir -ItemType Directory | Out-Null

  # Copy the role script
  Copy-Item "$templatesPath\Role.ps1.template" "$roleDir\Always.ps1"

  Write-Host "Role created at ""$roleDir"""
}

Export-ModuleMember -Function New-DeliveryRole