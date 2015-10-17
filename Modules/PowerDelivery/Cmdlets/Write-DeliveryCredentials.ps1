function Write-DeliveryCredentials {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $key,
    [Parameter(Position=1,Mandatory=1)][string] $userName
  )

  $credentialsPath = Join-Path (Get-Location) "Credentials"

  if (!(Test-Path $credentialsPath)) {
    New-Item $credentialsPath -ItemType Directory | Out-Null
  }

  $userNameFile = "$($userName -replace '\\', '#').credential"
  $userNamePath = Join-Path $credentialsPath $userNameFile

  Write-Host "Enter the password for $userName and press ENTER:"
  $keyBytes = [Convert]::FromBase64String($key)
  $password = Read-Host -AsSecureString | ConvertFrom-SecureString -Key $keyBytes | Out-File $userNamePath -Force

  Write-Host "Credentials exported to "".\Credentials\$userNameFile"""
}

Export-ModuleMember -Function Write-DeliveryCredentials