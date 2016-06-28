<#
.Synopsis
Encrypts a secret with a key and adds it to to a powerdelivery project.

.Description
Encrypts a secret with a key and adds it to to a powerdelivery project.

The secret will be created at the path:

.\Secrets\<KeyName>\<SecretName>.secret

.Example
New-DeliverySecret MyKey MySecret

.Parameter KeyName
The name of the key to use for encryption.

.Parameter SecretName
The name of the secret to encrypt.

.Parameter Force
Switch that forces overwrite of any existing secret file if found.
#>
function New-DeliverySecret {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $KeyName,
    [Parameter(Position=1,Mandatory=1)][string] $SecretName,
    [Parameter(Position=2,Mandatory=0)][switch] $Force
  )

  $projectDir = GetProjectDirectory
  $projectName = [IO.Path]::GetFileName($projectDir)

  ValidateNewFileName -FileName $SecretName -Description "secret name"
  
  $keyBytes = GetKeyBytes -ProjectDir $projectName -KeyName $KeyName -ThrowOnError

  $secretsPath = Join-Path (Get-Location) "Secrets\$KeyName"
  if (!(Test-Path $secretsPath)) {
    New-Item $secretsPath -ItemType Directory | Out-Null
  }

  $secretFile = "$(SecretName).secret"
  $secretPath = Join-Path $secretsPath $secretFile 
  if ((Test-Path $secretPath) -and (!$Force)) {
    throw "Secret at $secretPath exists. Pass -Force to overwrite."
  }

  Write-Host "Enter the secret value $SecretKey and press ENTER:"
  try {
    Read-Host -AsSecureString | ConvertFrom-SecureString -Key $keyBytes | Out-File $secretPath -Force
    Write-Host "Secret written to "".\Secrets\$KeyName\$secretFile"""
  }
  catch {
    "Key $KeyName appears to be invalid - $_"
  }
}

Export-ModuleMember -Function New-DeliverySecret
