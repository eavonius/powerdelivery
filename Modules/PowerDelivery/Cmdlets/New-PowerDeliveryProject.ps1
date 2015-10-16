function New-PowerDeliveryProject {
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

  Write-Host "Powerdelivery project created!" -ForegroundColor Green
}

Set-Alias pow:New New-PowerDeliveryProject
Export-ModuleMember -Function New-PowerDeliveryProject -Alias pow:New