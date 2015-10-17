function New-PowerDeliveryCredentialKey {
  $Key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
  [Convert]::ToBase64String($Key)
}

Set-Alias pow:credentials:key New-PowerDeliveryCredentialKey
Export-ModuleMember -Function New-PowerDeliveryCredentialKey -Alias pow:credentials:key