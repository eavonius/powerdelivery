function Invoke-PowerDelivery {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][Alias('t')][string] $Target,
    [Parameter(Position=1,Mandatory=1)][Alias('e')][string] $Environment,
    [Parameter(Position=2,Mandatory=0)][Alias('r')][string] $Revision
  )

  $pow.target = @{
    EnvironmentName = $Environment;
    TargetName = $Target;
    RequestedBy = (whoami).ToUpper();
    Revision = $Revision;
    StartDate = Get-Date;
    StartDir = Get-Location;
    StartedAt = Get-Date -Format "yyyyMMdd_hhmmss";
  }

  $pow.curDir = $pow.target.StartDir
  $pow.lastAction = ''
  $pow.inBuild = $true
  $pow.buildFailed = $false

  # Get roles from prior run
  $rolesToRemove = [System.Collections.ArrayList]@()
  foreach ($item in $pow.GetEnumerator()) {
    if ($item.Key.EndsWith('Role')) {
      $rolesToRemove.Add($item.Key)
    }
  }

  # Remove roles from prior run
  foreach ($roleToRemove in $rolesToRemove) {
    $pow.Remove($roleToRemove)
  }

  Write-Host "$($pow.product) v$($pow.version) started by $($pow.target.RequestedBy)" -ForegroundColor $pow.colors['SuccessForeground']

  try {
    Write-Host "Started Target ""$Target"" in ""$Environment"" Environment..."

    # Test for environment
    $envPath = "Environments\$Environment.ps1"
    $envScript = (Join-Path $pow.target.StartDir $envPath)
    if (!(Test-Path $envScript)) {
      Write-Host "Environment script $envPath could not be found." -ForegroundColor Red
      throw
    }

    # Load environment
    try {
      $pow.target.Environment = Invoke-Expression -Command $envScript
    }
    catch {
      Write-Host "Error occurred loading $envPath." -ForegroundColor Red
      throw
    }

    # Test for target
    $targetPath = "Targets\$Target.ps1"
    $targetScript = (Join-Path $pow.target.StartDir $targetPath)
    if (!(Test-Path $targetScript)) {
      Write-Host "Target script $targetPath could not be found." -ForegroundColor Red
      throw
    }

    # Load target
    try {
      $pow.targetScript = Invoke-Expression -Command $targetScript
    }
    catch {
      Write-Host "Error occurred loading $targetPath." -ForegroundColor Red
      throw
    }

    # Test for shared configuration
    $sharedConfigPath = "Configuration\_Shared.ps1"
    $sharedConfigScript = (Join-Path $pow.target.StartDir $sharedConfigPath)
    if (!(Test-Path $sharedConfigScript)) {
      Write-Host "Shared configuration script $sharedConfigPath could not be found." -ForegroundColor Red
      throw
    }

    # Load shared configuration
    try {
      $pow.sharedConfig = Invoke-Expression -Command $sharedConfigScript
    }
    catch {
      Write-Host "Error occurred loading $sharedConfigPath." -ForegroundColor Red
      throw
    }

    # Test for environment configuration
    $envConfigPath = "Configuration\$Environment.ps1"
    $envConfigScript = (Join-Path $pow.target.StartDir $envConfigPath)
    if (!(Test-Path $envConfigScript)) {
      Write-Host "Environment configuration script $envConfigPath could not be found." -ForegroundColor Red
      throw 
    }

    # Load environment configuration
    try {
      $pow.envConfig = Invoke-Command -ComputerName localhost -File $envConfigScript -ArgumentList $pow.sharedConfig
    }
    catch {
      Write-Host "Error occurred loading $envConfigPath." -ForegroundColor Red
      throw
    }

    $config = @{}

    # Add environment-specific config settings
    foreach ($envConfigSetting in $pow.envConfig.GetEnumerator()) {
      $config.Add($envConfigSetting.Key, $envConfigSetting.Value)
    }

    # Add shared config settings
    foreach ($sharedConfigSetting in $pow.sharedConfig.GetEnumerator()) {
      if (!($config.ContainsKey($sharedConfigSetting.Key))) {
        $config.Add($sharedConfigSetting.Key, $sharedConfigSetting.Value)
      }
    }

    # Iterate steps of the target
    foreach ($targetStep in $pow.targetScript.GetEnumerator()) {
        Write-Host "[------------ Target Step: ""$($targetStep.Key)""" -ForegroundColor $pow.colors['StepForeground']

        # Iterate sets of nodes in the step
        foreach ($node in $targetStep.Value.Nodes) {

          # Make sure the environment contains the nodes
          if (!($pow.target.Environment.ContainsKey($node))) {
            Write-Host "Step $($targetStep.Key) of Target $Target refers to NodeSet $node not found in $Environment environment." -ForegroundColor Red
            throw
          }

          $nodeNames = $pow.target.Environment[$node]

          # Iterate nodes in the set
          foreach ($nodeName in $nodeNames) {

            # Iterate roles
            foreach ($role in $targetStep.Value.Roles) {

              # Make sure the role script exists
              if (!($pow.ContainsKey("$($role)Role"))) {
                $rolePath = "Roles\$role\Tasks.ps1"
                $roleScript = (Join-Path $pow.target.StartDir $rolePath)
                if (!(Test-Path $roleScript)) {
                  Write-Host "Role script $rolePath could not be found." -ForegroundColor Red
                  throw 
                }

                # Run the role script to get the script block              
                Invoke-Expression -Command ".\$rolePath"
              }

              Write-Host "[------------ Role ""$role"" -> ($nodeName)" -ForegroundColor $pow.colors['RoleForeground']

              # Run the script block
              Invoke-Command -ScriptBlock $pow["$($role)Role"] -ArgumentList @($pow.target, $config, $nodeName)

              Set-Location $pow.target.StartDir
            }
          }
        }
    }
  }
  catch {
    $pow.buildFailed = $true
    #Write-Host (Format-Error $_) -ForegroundColor $pow.colors['FailureForeground']
    throw
  }
  finally {
    $build_time = New-Timespan -Start ($pow.target.StartDate) -End (Get-Date)
    $build_time_string = ''

    $build_time_days = $build_time.Days
    if ($build_time_days -gt 0) {
      $build_time_string += "$build_time_days days"
    }

    $build_time_hours = $build_time.Hours
    if ($build_time_hours -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' and '
      }
      $build_time_string += "$build_time_hours hours"
    }

    $build_time_minutes = $build_time.Minutes
    if ($build_time_minutes -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' and '
      }
      $build_time_string += "$build_time_minutes minutes"
    }

    $build_time_seconds = $build_time.Seconds
    if ($build_time_seconds -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' and '
      }
      $build_time_string += "$build_time_seconds seconds"
    }

    $build_time_ms = $build_time.Milliseconds
    if ($build_time_ms -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' and '
      }
      $build_time_string += "$build_time_ms ms"
    }

    if ($pow.buildFailed) {
      Write-Host "$($pow.product) build failed in $build_time_string" -ForegroundColor $pow.colors['FailureForeground']
    }
    else {
      Write-Host "$($pow.product) build succeeded in $build_time_string" -ForegroundColor $pow.colors['SuccessForeground']
    }

    Set-Location $pow.target.StartDir | Out-Null

    $pow.inBuild = $false
  }
}

Set-Alias pow Invoke-PowerDelivery
Export-ModuleMember -Function Invoke-PowerDelivery -Alias pow
