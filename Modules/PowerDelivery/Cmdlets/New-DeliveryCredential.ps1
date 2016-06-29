<#
.Synopsis
Encrypts a set of credentials with a key and adds them to a powerdelivery project.

.Description
Encrypts a set of credentials with a key and adds them to a powerdelivery project.

.Example
New-DeliveryCredentials MyKey "MYDOMAIN\myuser"

The credential will be created at the path:

.\Secrets\<KeyName>\Credentials\<UserName>.credential

.Parameter KeyName
The name of the key to use for encryption.

.Parameter UserName
The username of the account to encrypt the password for.

.Parameter Force
Switch that forces overwrite of any existing credential file if found.
#>
function New-DeliveryCredential {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $KeyName,
    [Parameter(Position=1,Mandatory=1)][string] $UserName,
    [Parameter(Position=2,Mandatory=0)][switch] $Force
  )

  $projectDir = GetProjectDirectory
  $projectName = [IO.Path]::GetFileName($projectDir)

  $userFileName = $UserName -replace '\\', '#'

  ValidateNewFileName -FileName $userFileName -Description "username"
  
  $keyBytes = GetKeyBytes -ProjectDir $projectName -KeyName $KeyName -ThrowOnError

  $credentialsPath = Join-Path (Get-Location) "Secrets\$KeyName\Credentials"
  if (!(Test-Path $credentialsPath)) {
    New-Item $credentialsPath -ItemType Directory | Out-Null
  }

  $userNameFile = "$($userFileName).credential"
  $userNamePath = Join-Path $credentialsPath $userNameFile

  if ((Test-Path $userNamePath) -and (!$Force)) {
    throw "Credential at $userNamePath exists. Pass -Force to overwrite."
  }

  Write-Host "Enter the password for $userName and press ENTER:"
  try {
    Read-Host -AsSecureString | ConvertFrom-SecureString -Key $keyBytes | Out-File $userNamePath -Force
    Write-Host "Credential written to "".\Secrets\$KeyName\Credentials\$userNameFile"""
  }
  catch {
    "Key $KeyName appears to be invalid - $_"
  }
}

Export-ModuleMember -Function New-DeliveryCredential
