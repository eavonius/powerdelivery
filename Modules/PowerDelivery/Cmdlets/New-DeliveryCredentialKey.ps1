function New-DeliveryCredentialKey {
  [CmdletBinding()]
  param()
  $Key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
  [Convert]::ToBase64String($Key)
}

Export-ModuleMember -Function New-DeliveryCredentialKey