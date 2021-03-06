<# PowerDelivery.psm1

Script for PowerShell module.

http://www.powerdelivery.io
#>

function GetProjectDirectory {
  if (!((Test-Path 'Targets') -and (Test-Path 'Environments') -and (Test-Path 'Roles'))) {
    throw "This command must be run from within a powerdelivery project directory."
  }
  Get-Location
}

function ValidateNewFileName($Type, $FileName) {
  $isValidName = "^[a-zA-Z0-9@#_\.\-]+$"
  if (!($FileName -match $isValidName)) {
    throw "Please use a $Type that only includes alphanumeric characters, @ sign, pound sign, underscore, period or dash, and no spaces."
  }
}

function GetMyDocumentsFolder {
  [Environment]::GetFolderPath("MyDocuments")
}

function GetKeyBytes($ProjectDir, $KeyName, [switch]$ThrowOnError) {
  $myDocumentsFolder = GetMyDocumentsFolder
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

function GetNewKey {
  $key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
  [Convert]::ToBase64String($key)
}

# Load cmdlets
$cmdletsDir = (Join-Path $PSScriptRoot "Cmdlets")
gci $cmdletsDir -Filter "*.ps1" | ForEach-Object { . (Join-Path $cmdletsDir $_.Name) }

$env:TERM = "msys"

$script:pow = @{}
$pow.scriptDir = Split-Path $MyInvocation.MyCommand.Path
