function Write-DeliveryCredentials {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $KeyName,
    [Parameter(Position=1,Mandatory=1)][string] $UserName,
    [Parameter(Position=2,Mandatory=0)][switch] $Force
  )

  $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
  $keysFolderPath = Join-Path $myDocumentsFolder "PowerDelivery\Keys"
  $keyFilePath = Join-Path $keysFolderPath "$KeyName.key"

  if (!(Test-Path $keyFilePath)) {
    throw "Key not found at $keyFilePath."
  }

  $keyString = Get-Content $keyFilePath

  $credentialsPath = Join-Path (Get-Location) "Credentials"

  if (!(Test-Path $credentialsPath)) {
    New-Item $credentialsPath -ItemType Directory | Out-Null
  }

  $userNameFile = "$($UserName -replace '\\', '#').credential"
  $userNamePath = Join-Path $credentialsPath $userNameFile

  if ((Test-Path $userNamePath) -and (!$Force)) {
    throw "Credentials at $userNamePath exist. Pass -Force to overwrite."
  }

  Write-Host "Enter the password for $userName and press ENTER:"
  $keyBytes = [Convert]::FromBase64String($keyString)

  try {
    Read-Host -AsSecureString | ConvertFrom-SecureString -Key $keyBytes | Out-File $userNamePath -Force
    Write-Host "Credentials written to "".\Credentials\$keyName\$userNameFile"""
  }
  catch {
    "$keyFilePath appears to be invalid - $_"
  }
}

Export-ModuleMember -Function Write-DeliveryCredentials