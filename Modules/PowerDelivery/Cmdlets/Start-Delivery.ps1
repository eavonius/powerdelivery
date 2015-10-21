function Start-Delivery {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][Alias('p')][string] $ProjectName,
    [Parameter(Position=1,Mandatory=1)][Alias('t')][string] $TargetName,
    [Parameter(Position=2,Mandatory=1)][Alias('e')][string] $EnvironmentName,
    [Parameter(Position=3,Mandatory=0)][Alias('r')][string] $Revision,
    [Parameter(Position=4,Mandatory=0)][Alias('a')][string] $As,
    [Parameter(Position=5,Mandatory=0)][Alias('c')][string] $UseCredentials
  )

  $ErrorActionPreference = 'Stop'

  winrm quickconfig -Force | Out-Null
  Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null

  # Verify running as Administrator
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  if (!(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw "Please run PowerDelivery using an elevated (Administrative) command prompt."
  }

  $pow.colors = @{
    SuccessForeground = 'Green'; 
    FailureForeground = 'Red'; 
    StepForeground = 'Magenta'; 
    RoleForeground = 'Yellow';
    CommandForeground = 'White'; 
    LogFileForeground = 'White' 
  }

  $pow.target = @{
    ProjectName = $ProjectName;
    TargetName = $TargetName;
    EnvironmentName = $EnvironmentName;
    Revision = $Revision;
    RequestedBy = (whoami).ToUpper();
    StartDate = Get-Date;
    StartDir = Get-Location;
    StartedAt = Get-Date -Format "yyyyMMdd_hhmmss";
    Credentials = New-Object "System.Collections.Generic.Dictionary[String, System.Management.Automation.PSCredential]"
  }

  $pow.curDir = $pow.target.StartDir
  $pow.lastAction = ''
  $pow.inBuild = $true
  $pow.buildFailed = $false

  $pow.roles = @{}
  $pow.variableBlocks = @{}

  if (Get-Module powerdelivery)
  {
      $pow.version = Get-Module powerdelivery | select version | ForEach-Object { $_.Version.ToString() }
  }
  else
  {
      $pow.version = "SOURCE"
  }

  Write-Host
  Write-Host "PowerDelivery v$($pow.version)" -ForegroundColor $pow.colors['SuccessForeground']
  Write-Host "Target ""$TargetName"" started by ""$($pow.target.RequestedBy)"""

  try {
    Write-Host "Delivering ""$ProjectName"" to ""$EnvironmentName"" environment..."
    Write-Host

    $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")

    # Test for credentials
    $credsPath = "$($ProjectName)Delivery\Credentials"
    if (Test-Path $credsPath) {

      # Iterate credential key directories
      foreach ($keyDirectory in (Get-ChildItem -Directory $credsPath)) {
        $keyFilePath = Join-Path $myDocumentsFolder "PowerDelivery\Keys\$keyDirectory.key"
        if (Test-Path $keyFilePath) {

          # Load key file
          $keyString = Get-Content $keyFilePath
          $keyBytes = $null
          try {
            $keyBytes = [Convert]::FromBase64String($keyString)
          }
          catch {
            throw "Key at $keyFilePath is invalid - $_"
          }

          # Iterate credentials
          $keyCredsPath = Join-Path $credsPath $keyDirectory
          foreach ($credentialsFile in (Get-ChildItem $keyCredsPath)) {

            $credsFullPath = Join-Path $keyCredsPath $credentialsFile

            $password = $null
            try {
              $password = Get-Content $credsFullPath | ConvertTo-SecureString -Key $keyBytes
            }
            catch {
              throw "Couldn't decrypt $credsFullPath with key in $keyFilePath - $_"
            }

            # Fix up the username
            $credsFileUserName = $credentialsFile -replace '#', '\\'
            $userName = [IO.Path]::GetFileNameWithoutExtension($credsFileUserName)

            # Create the PowerShell credential
            $userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $password

            # Add credentials to hash in target
            $pow.target.Credentials.Add($userName.ToLower(), [PSCredential]$userCredential)
          }
        }
      }
    }

    $defaultRemoteCredentials = $null

    # Lookup remote credentials if specified
    if (![String]::IsNullOrWhiteSpace($UseCredentials)) {
      if (!$pow.target.Credentials.ContainsKey($UseCredentials.ToLower())) {
        throw "Credentials $UseCredentials not found. Are you missing the key file?"
      }
      else {
        $defaultRemoteCredentials = $pow.target.Credentials.Item($UseCredentials.ToLower())
      }
    }

    # Test for shared configuration
    $sharedConfigPath = "$($ProjectName)Delivery\Configuration\_Shared.ps1"
    $sharedConfigScript = (Join-Path $pow.target.StartDir $sharedConfigPath)
    if (!(Test-Path $sharedConfigScript)) {
      Write-Host "Shared configuration script $sharedConfigPath could not be found." -ForegroundColor Red
      throw
    }

    # Load shared configuration
    try {
      $pow.sharedConfig = Invoke-Command -ComputerName localhost -File $sharedConfigScript -ArgumentList $pow.target
    }
    catch {
      Write-Host "Error occurred loading $sharedConfigPath." -ForegroundColor Red
      throw
    }

    # Test for environment configuration
    $envConfigPath = "$($ProjectName)Delivery\Configuration\$EnvironmentName.ps1"
    $envConfigScript = (Join-Path $pow.target.StartDir $envConfigPath)
    if (!(Test-Path $envConfigScript)) {
      Write-Host "Environment configuration script $envConfigPath could not be found." -ForegroundColor Red
      throw 
    }

    # Load environment configuration
    try {
      $pow.envConfig = Invoke-Command -ComputerName localhost -File $envConfigScript -ArgumentList @($pow.target, $pow.sharedConfig)
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

    # Test for environment
    $envPath = "$($ProjectName)Delivery\Environments\$EnvironmentName.ps1"
    $envScript = (Join-Path $pow.target.StartDir $envPath)
    if (!(Test-Path $envScript)) {
      Write-Host "Environment script $envPath could not be found." -ForegroundColor Red
      throw
    }

    # Load environment
    try {
      $pow.target.Environment = Invoke-Command -ComputerName localhost -File $envScript -ArgumentList @($pow.target, $config)
    }
    catch {
      Write-Host "Error occurred loading $envPath." -ForegroundColor Red
      throw
    }

    # Test for target
    $targetPath = "$($ProjectName)Delivery\Targets\$TargetName.ps1"
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

    # Iterate steps of the target
    foreach ($targetStep in $pow.targetScript.GetEnumerator()) {
      Write-Host "[----- $($targetStep.Key)" -ForegroundColor $pow.colors['StepForeground']

      # Iterate sets of nodes in the step
      foreach ($node in $targetStep.Value.Nodes) {

        # Make sure the environment contains the nodes
        if (!$pow.target.Environment.ContainsKey($node)) {
          Write-Host "Step $($targetStep.Key) of target $TargetName refers to nodeset $node not found in $EnvironmentName environment." -ForegroundColor Red
          throw
        }

        $nodes = $pow.target.Environment.Item($node)

        # Iterate nodes in the set
        foreach ($nodeName in $nodes.Nodes) {

          # Iterate roles
          foreach ($role in $targetStep.Value.Roles) {

            # Make sure the role script exists
            if (!($pow.roles.ContainsKey($role))) {
              $rolePath = "$($ProjectName)Delivery\Roles\$role\Always.ps1"
              $roleScript = (Join-Path $pow.target.StartDir $rolePath)
              if (!(Test-Path $roleScript)) {
                Write-Host "Role script $rolePath could not be found." -ForegroundColor Red
                throw 
              }#

              # Run the role script to get the script block              
              Invoke-Expression -Command ".\$rolePath"
            }

            Write-Host "[--------- $role -> ($nodeName)" -ForegroundColor $pow.colors['RoleForeground']

            $commandArgs = @{
              ScriptBlock = $pow.roles.Item($role)[0];
              ArgumentList = @($pow.target, $config, $nodeName)
            }

            # Add the node name if not localhost
            if ($nodeName.ToLower() -ne 'localhost') {
              $commandArgs.Add('ComputerName', $nodeName)
              $commandArgs.Add('EnableNetworkAccess', 1)

              # Add remote credentials if specified
              if ($defaultRemoteCredentials -ne $null) {
                $commandArgs.Add('Credential', $defaultRemoteCredentials)

                $authentication = 'Default'

                if ($nodes.ContainsKey('Authentication')) {
                  $authentication = $nodes['Authentication']
                }

                $commandArgs.Add('Authentication', $authentication)

                # Setup CredSSP if specified
                if ($authentication.ToLower() -eq 'credssp') {
                  $credSSP = Get-WSManCredSSP
                  $nodeExists = $false

                  # Check whether remote node exists in trusted hosts
                  if ($credSSP -ne $null) {
                    if ($credSSP.length -gt 0) {
                      $trustedClients = $credSSP[0].Substring($credSSP[0].IndexOf(":") + 2)
                      $trustedClientsList = $trustedClients -split "," | % { $_.Trim() }
                      if ($trustedClientsList.Contains("wsman/$($nodeName.ToLower())")) {
                        $nodeExists = $true
                      }
                    }
                  }

                  # Enable CredSSP to remote node if not found in trusted hosts
                  if (!$nodeExists) {
                    Enable-WSManCredSSP -Role Client -DelegateComputer $nodeName.ToLower() -Force | Out-Null
                  }
                }
              }
            }

            # Run the role
            Invoke-Command @commandArgs

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
        $build_time_string += ' '
      }
      $build_time_string += "$build_time_hours hrs"
    }

    $build_time_minutes = $build_time.Minutes
    if ($build_time_minutes -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' '
      }
      $build_time_string += "$build_time_minutes min"
    }

    $build_time_seconds = $build_time.Seconds
    if ($build_time_seconds -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' '
      }
      $build_time_string += "$build_time_seconds sec"
    }

    $build_time_ms = $build_time.Milliseconds
    if ($build_time_ms -gt 0) {
      if ($build_time_string.Length -gt 0) {
        $build_time_string += ' '
      }
      $build_time_string += "$build_time_ms ms"
    }

    Write-Host

    if ($pow.buildFailed) {
      Write-Host "Target ""$TargetName"" failed in $build_time_string." -ForegroundColor $pow.colors['FailureForeground']
    }
    else {
      Write-Host "Target ""$TargetName"" succeeded in $build_time_string." -ForegroundColor $pow.colors['SuccessForeground']
    }

    Set-Location $pow.target.StartDir | Out-Null

    $pow.inBuild = $false
  }
}

Export-ModuleMember -Function Start-Delivery