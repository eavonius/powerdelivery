<#
PowerDelivery.psm1

powerdelivery - http://eavonius.github.com/powerdelivery

PowerShell module that enables writing build scripts that follow continuous delivery 
principles and deploy product assets into multiple environments.
#>

function GetProjectDirectory {
  if (!((Test-Path 'Targets') -and (Test-Path 'Environments') -and (Test-Path 'Roles'))) {
    throw "This command must be run from within a powerdelivery project directory."
  }
  [IO.Path]::GetFileName($(Get-Location))
}

function ValidateNewFileName($Type, $FileName) {
  $isValidName = "^[a-zA-Z0-9]+$"
  if (!($FileName -match $isValidName)) {
    throw "Please use a $Type that only includes alphanumeric characters and no spaces."
  }
}

function GetKeyBytes($ProjectDir, $KeyName, [switch]$ThrowOnError) {
  $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
  $keysFolderPath = Join-Path $myDocumentsFolder "PowerDelivery\Keys\$ProjectDir"
  $keyFilePath = Join-Path $keysFolderPath "$KeyName.key"

  if (!(Test-Path $keyFilePath)) {
    if ($ThrowOnError) {
      throw "Key not found at $keyFilePath."
    }
    else {
      return $null
    }
  }
  $keyString = Get-Content $keyFilePath
  try {
    [Convert]::FromBase64String($keyString)
  }
  catch {
    throw "Key $KeyName is invalid - $_"
  }
}

# Load cmdlets
$cmdletsDir = (Join-Path $PSScriptRoot "Cmdlets")
gci $cmdletsDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $cmdletsDir $_.Name) }

$env:TERM = "msys"

$script:pow = @{}
$pow.scriptDir = Split-Path $MyInvocation.MyCommand.Path
