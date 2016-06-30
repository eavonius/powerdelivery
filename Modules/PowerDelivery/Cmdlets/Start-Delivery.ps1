<#
.Synopsis
Starts deployment or rollback of a target with powerdelivery.

.Description
Starts deployment or rollback of a target with powerdelivery. Must be run in the parent directory of your powerdelivery project.

.Example
Start-Delivery MyApp Release Production

.Parameter ProjectName
The name of the project. Powerdelivery looks for a subdirectory with this name suffixed with "Delivery".

.Parameter TargetName
The name of the target to run. Must match the name of a file in the Targets subdirectory of your powerdelivery project without the file extension.

.Parameter EnvironmentName
The name of the environment to target during the run. Must match the name of a file in the Environments subdirectory of your powerdelivery project without the file extension.

.Parameter Properties
A hash of properties to pass to the target. Typically used to pass information from build servers.

.Parameter Rollback
Switch that when set causes the Down block of roles to be called instead of Up, performing a rollback.
#>
function Start-Delivery {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $ProjectName,
    [Parameter(Position=1,Mandatory=1)][string] $TargetName,
    [Parameter(Position=2,Mandatory=1)][string] $EnvironmentName,
    [Parameter(Position=3,Mandatory=0)][hashtable] $Properties = @{},
    [Parameter(Position=4,Mandatory=0)][switch] $Rollback
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
    StartedAt = Get-Date -Format "yyyyMMdd_HHmmss";
    Properties = $Properties;
    Credentials = New-Object "System.Collections.Generic.Dictionary[String, System.Management.Automation.PSCredential]";
    Secrets = @{}
  }

  $pow.buildFailed = $false
  $pow.inBuild = $true
  $pow.roles = @{}

  # Get the running version of powerdelivery
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
  
  function LoadRoleScript($role) {

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
  }

  # Writes the starting status message for a role
  #
  function WriteRoleStart($role, $hostOrConnectionURI) {

    Write-Host "[--------- $role -> ($hostOrConnectionURI)" -ForegroundColor $pow.colors['RoleForeground']
  }

  # Invokes a role on a host
  #
  function InvokeRoleOnHost($nodes, $role, $hostName) {

    LoadRoleScript -role $role
    WriteRoleStart -role $role -hostOrConnectionURI $hostName

    InvokeRole -nodes $nodes -role $role -hostName $hostName
  }

  # Invokes a role on a connection
  function InvokeRoleOnConnection($nodes, $role, $connectionURI) {

    LoadRoleScript -role $role
    WriteRoleStart -role $role -hostOrConnectionURI $connectionURI

    InvokeRole -nodes $nodes -role $role -connectionURI $connectionURI
  }

  # Invokes a role
  #
  function InvokeRole($nodes, $role, $hostName, $connectionURI) {

    $hostOrConnectionURI = $hostName

    if ([String]::IsNullOrWhiteSpace($hostName)) {
      $hostOrConnectionURI = $connectionURI
    }

    # Determine whether to roll up or down
    $blockToRun = $pow.roles.Item($role)[0];
    if ($Rollback) {
      $blockToRun = $pow.roles.Item($role)[1];
    }

    # Must have a rollback or up block to run
    if ($blockToRun) {

      $commandArgs = @{
        ScriptBlock = $blockToRun;
        ArgumentList = @($pow.target, $config, $hostOrConnectionURI)
      }

      # Check whether a remote node
      if ([String]::IsNullOrWhiteSpace($hostName) -or ($hostName.ToLower() -ne 'localhost')) {

        # Set the computer name or connection URI
        if ([String]::IsNullOrWhiteSpace($connectionURI)) {
          $commandArgs.Add('ComputerName', $hostName)
        }
        else {
          $commandArgs.Add('ConnectionURI', $connectionURI) 
          if ($nodes.ContainsKey('UseSSL')) {
            throw "Role $role cannot set UseSSL and Connection together."
          }
        }

        $commandArgs.Add('EnableNetworkAccess', 1)

        # Lookup remote credentials if specified
        if ($nodes.ContainsKey('Credential')) {
          $credentialName = $nodes.Credential
          if (!$pow.target.Credentials.ContainsKey($credentialName)) {
            throw "Role $role requires credential $credentialName which were not loaded. Are you missing the key file?"
          }
          else {
            Write-Host "Using credentials $credentialName"
            $commandArgs.Add('Credential', $pow.target.Credentials.Item($credentialName))
          }
        }

        # Add UseSSL if specified
        if ($nodes.ContainsKey('UseSSL')) {
          $commandArgs.Add('UseSSL', 1);
        }

        # Add authentication options if using credentials
        if ($commandArgs.ContainsKey('Credential')) {

          $authentication = 'Default'

          # Update authentication of the command if specified on the nodes
          if ($nodes.ContainsKey('Authentication')) {
            $authentication = $nodes.Authentication
          } 

          # Set authentication of the command
          $commandArgs.Add('Authentication', $authentication)

          # Setup CredSSP if specified
          if ($authentication.ToLower() -eq 'credssp') {

            $trustedHost = $hostName

            # Verify that a host was specified
            if ([String]::IsNullOrWhiteSpace($hostName)) {
              $uri = New-Object System.Uri -ArgumentList $connectionURI
              $trustedHost = $uri.Host
            }
         
            $credSSP = Get-WSManCredSSP
            $nodeExists = $false

            # Check whether remote node exists in trusted hosts
            if ($credSSP -ne $null) {
              if ($credSSP.length -gt 0) {
                $trustedClients = $credSSP[0].Substring($credSSP[0].IndexOf(":") + 2)
                $trustedClientsList = $trustedClients -split "," | % { $_.Trim().ToLower() }
                if ($trustedClientsList.Contains("wsman/$($trustedHost.ToLower())")) {
                  Write-host """$($trustedHost)"" is trusted for CredSSP delegation."
                  $nodeExists = $true
                }
              }
            }

            # Enable CredSSP to remote node if not found in trusted hosts
            if (!$nodeExists) {
              Write-Host "Enabling CredSSP delegation to ""$($trustedHost)""..."
              Enable-WSManCredSSP -Role Client -DelegateComputer $trustedHost -Force | Out-Null
            }
          }
        }
      }

      # Run the role
      try {
        Invoke-Command @commandArgs
      }
      catch {
        throw "Error in role ""$role"" on $hostOrConnectionURI" + [Environment]::NewLine, $_
      }

      Set-Location $pow.target.StartDir
    }
  }

  try {
    if ($Rollback) {
      Write-Host "Rolling back ""$ProjectName"" in ""$EnvironmentName"" environment..."
    }
    else {
      Write-Host "Delivering ""$ProjectName"" to ""$EnvironmentName"" environment..."
    }
    Write-Host

    $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")

    # Test for secrets
    $secretsPath = "$($ProjectName)Delivery\Secrets"
    if (Test-Path $secretsPath) {

      # Iterate secret key directories
      foreach ($keyDirectory in (Get-ChildItem -Directory $secretsPath)) {

        # Try to get the key
        $keyBytes = GetKeyBytes -ProjectDir "$($ProjectName)Delivery" -KeyName $keyDirectory

        if ($keyBytes -ne $null) {

          # Iterate secrets
          foreach ($secretFile in (Get-ChildItem -File -Filter *.secret $keyDirectory.FullName)) { 

            $secretName = [IO.Path]::GetFileNameWithoutExtension($secretFile)
            $secretFullPath = Join-Path $keyDirectory $secretFile

            # Try to decrypt the secret
            $secret = $null
            try {
              $secret = Get-Content $secretFullPath | ConvertTo-SecureString -Key $keyBytes
            }
            catch {
              throw "Couldn't decrypt $secretFullPath with key $keyDirectory - $_"
            }

            # Add secret to hash in target
            $pow.target.Secrets.Add($secretName, $secret)
          }

          # Test for credentials
          $credsPath = Join-Path $keyDirectory.FullName Credentials
          if (Test-Path $credsPath) {

            # Iterate credentials
            foreach ($credentialsFile in (Get-ChildItem -File -Filter *.credential $credsPath)) {

              $credsFullPath = Join-Path $credsPath $credentialsFile

              # Try to decrypt the password
              $password = $null
              try {
                $password = Get-Content $credsFullPath | ConvertTo-SecureString -Key $keyBytes
              }
              catch {
                throw "Couldn't decrypt $credsFullPath with key $keyDirectory - $_"
              }

              # Fix up the username
              $credsFileName = [IO.Path]::GetFileNameWithoutExtension($credentialsFile)
              $userName = $credsFileName -replace '#', '\'

              # Create the PowerShell credential
              $userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $password

              # Add credentials to hash in target
              $pow.target.Credentials.Add($userName, [PSCredential]$userCredential)
            }
          }
        }
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

        # Get the current set of nodes for the target
        $nodes = $pow.target.Environment.Item($node)

        # Make sure they didn't specify hosts and connections together
        if ($nodes.ContainsKey('Hosts') -and $nodes.ContainsKey('Connections')) {
          throw "Nodes $node cannot combine Hosts and Connections."
        }

        # Iterate hosts in the set
        if ($nodes.ContainsKey('Hosts')) {
          foreach ($hostName in $nodes.Hosts) {
            # Iterate roles
            foreach ($role in $targetStep.Value.Roles) {
              InvokeRoleOnHost -nodes $nodes -role $role -hostName $hostName
            }
          }
        }
        # Iterate connections in the set
        elseif ($nodes.ContainsKey('Connections')) {
          # Iterate connections in the set
          foreach ($connectionURI in $nodes.Connections) {
            # Iterate roles
            foreach ($role in $targetStep.Value.Roles) {
              InvokeRoleOnConnection -nodes $nodes -role $role -connectionURI $connectionURI
            }
          }
        }
      }
    }
  }
  catch {
    $pow.buildFailed = $true
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
  }
}

Export-ModuleMember -Function Start-Delivery
