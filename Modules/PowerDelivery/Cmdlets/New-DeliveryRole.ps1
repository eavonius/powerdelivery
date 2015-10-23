<#
.Synopsis
Generates a new powerdelivery role.

.Description
Generates a new powerdelivery role.

The role will be created at the path:

.\Roles\<RoleName>

.Example
New-DeliveryRole Database

.Parameter RoleNames
A comma-separated list of one or more names of roles to create.
#>
function New-DeliveryRole {
  param(
    [Parameter(Position=1,Mandatory=1)][string[]] $RoleName
  )

  $projectDir = GetProjectDirectory

  ValidateNewFileName -FileName $RoleName -Description "role name"

  $templatesPath = Join-Path $pow.scriptDir "Templates"

  foreach ($role in $RoleName) {

    $roleDir = ".\Roles\$role"

    if (Test-Path $roleDir) {
      throw "Directory $roleDir already exists."
    }

    New-Item $roleDir -ItemType Directory | Out-Null

    # Copy the role script
    Copy-Item "$templatesPath\Role.ps1.template" "$roleDir\Always.ps1"

    Write-Host "Role created at ""$roleDir"""
  }
}

Export-ModuleMember -Function New-DeliveryRole