<#
.Synopsis
Creates a new powerdelivery project.

.Description
The New-DeliveryProject cmdlet generates the files needed to work with powerdelivery.

.Example
New-DeliveryProject MyApp 'Local', 'Test', 'Production'

.Parameter ProjectName
Required. The name of the project to create.

.Parameter Environments
Optional. An array of the names of environments to create configuration variable and environment scripts for.
#>
function New-DeliveryProject {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][Alias('p')][string] $ProjectName,
    [Parameter(Position=1,Mandatory=0)][Alias('e')] $Environments
  )

  $templatesPath = Join-Path $pow.scriptDir "Templates"

  $projectDir = "$($ProjectName)Delivery"

  if (Test-Path $projectDir) {
    throw "Directory $projectDir already exists."
  }

  $configurationDir = "$projectDir\Configuration"
  $credentialsDir = "$projectDir\Credentials"
  $environmentsDir = "$projectDir\Environments"
  $rolesDir = "$projectDir\Roles"
  $targetsDir = "$projectDir\Targets"

  $dirsToCreate = @($configurationDir, $credentialsDir, $environmentsDir, $rolesDir, $targetsDir)

  # Create directories
  foreach ($dirToCreate in $dirsToCreate) {
    New-Item $dirToCreate -ItemType Directory | Out-Null
  }

  # Copy the default target script
  Copy-Item "$templatesPath\Target.ps1.template" "$targetsDir\Release.ps1"

  # Copy the shared configuration variables script
  Copy-Item "$templatesPath\_Shared.ps1.template" "$configurationDir\_Shared.ps1"

  if ($Environments -ne $null) {
    foreach ($environment in $Environments) {

      # Copy the environment configuration variables script
      Copy-Item "$templatesPath\Configuration.ps1.template" "$configurationDir\$environment.ps1"

      # Copy the environment nodes script
      Copy-Item "$templatesPath\Environment.ps1.template" "$environmentsDir\$environment.ps1"
    }
  }

  Write-Host "Project successfully created at "".\$($ProjectName)Delivery"""
}

Export-ModuleMember -Function New-DeliveryProject