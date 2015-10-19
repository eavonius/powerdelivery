function New-DeliveryKey {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][string] $KeyName
  )

  $key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
  $keyString = [Convert]::ToBase64String($key)

  $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
  $keysFolderPath = Join-Path $myDocumentsFolder "PowerDelivery\Keys"
  $keyFilePath = Join-Path $keysFolderPath "$KeyName.key"

  if (Test-Path $keyFilePath) {
    throw "Key $keyFilePath already exists."
  }

  $keyString | Out-File -FilePath $keyFilePath

  Write-Host "Key written to $keyFilePath."
}

Export-ModuleMember -Function New-DeliveryKey