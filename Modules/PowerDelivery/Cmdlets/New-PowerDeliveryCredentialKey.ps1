function New-PowerDeliveryCredentialKey {
  $Key = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
  Write-Host [Convert]::ToBase64String($Key)
}

Set-Alias pow:CredentialKey New-PowerDeliveryCredentialKey
Export-ModuleMember -Function New-PowerDeliveryCredentialKey -Alias pow:CredentialKey