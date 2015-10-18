function Get-DeliveryCredentials {
  [CmdletBinding()]
  param (
    [Parameter(Position=0,Mandatory=1)][string] $keyName,
    [Parameter(Position=2,Mandatory=1)][string] $userName
  )

  $myDocumentsFolder = [Environment]::GetFolderPath("MyDocuments")
  $keyFilePath = Join-Path $myDocumentsFolder "PowerDelivery\Keys\$keyName.key"

  if (!(Test-Path $keyFilePath)) {
    throw "Key file $keyFilePath not found."
  }

  $keyString = Get-Content $keyFilePath

  $credentialFileName = $userName -replace '\\', '#'
  $credentialsFile = Join-Path (Get-Location) "$($pow.target.ProjectName)Delivery\Credentials\$keyName\$credentialFileName.credential"

  if (!(Test-Path $credentialsFile)) {
    throw "Credential file $credentialsFile not found."
  }

  $keyBytes = $null

  try {
    $keyBytes = [Convert]::FromBase64String($keyString)
  }
  catch {
    "Key in $keyName environment variable is invalid - $_"
  }

  $password = $null

  try {
    $password = Get-Content $credentialsFile | ConvertTo-SecureString -Key $keyBytes
  }
  catch {
    throw "Couldn't decrypt $credentialsFile with key in $keyFilePath - $_"
  }

  New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $password  
}

Export-ModuleMember -Function Get-DeliveryCredentials