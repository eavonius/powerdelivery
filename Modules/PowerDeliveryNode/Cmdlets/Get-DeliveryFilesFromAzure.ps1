function Get-DeliveryFilesFromAzure {
  param(
    [Parameter(Position=0,Mandatory=1)][hashtable] $Target,
    [Parameter(Position=1,Mandatory=1)][string] $Path,
    [Parameter(Position=2,Mandatory=1)][string] $Destination,
    [Parameter(Position=3,Mandatory=1)][PSCredential] $Credential,
    [Parameter(Position=4,Mandatory=1)][string] $SubscriptionId,
    [Parameter(Position=5,Mandatory=1)][string] $StorageAccountName,
    [Parameter(Position=6,Mandatory=1)][string] $StorageAccountKey,
    [Parameter(Position=7,Mandatory=1)][string] $StorageContainer
  )

  $verbose = Test-Verbose

  if (-not ("win32.Shell" -as [type])) {
      Add-Type -Namespace win32 -Name Shell -MemberDefinition @"
      [DllImport("Shlwapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern bool PathRelativePathTo(System.Text.StringBuilder lpszDst,
      string From, System.IO.FileAttributes attrFrom, String to, System.IO.FileAttributes attrTo);
"@
  }

  Import-Module Azure

  # Set the active Azure account
  Add-AzureAccount -Credential $Credential | Out-Null

  if ($verbose) {
    Write-Host "Using Azure subscription ""$SubscriptionId"""
  }

  # Set the active subscription
  Select-AzureSubscription -SubscriptionId $SubscriptionId

  if ($verbose) {
    Write-Host "Using Azure storage account ""$StorageAccountName"""
  }

  # Connect to the Azure storage account
  $storageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName `
                                            -StorageAccountKey $StorageAccountKey
  
  # Get the powerdelivery share
  $releasesContainer = Get-AzureStorageContainer -Name $StorageContainer `
                                                 -Context $storageContext `
                                                 -ErrorAction SilentlyContinue
  if (!$releasesContainer) {
    throw "Azure storage container $StorageContainer not found in account $StorageAccountName."
  }

  $allReleaseFiles = Get-AzureStorageBlob -Blob "$($target.ProjectName)*" `
                                          -Container $StorageContainer `
                                          -Context $storageContext

  $pathToGet = "$($target.ProjectName)\$($target.StartedAt)"

  if ($Destination -ne ".") {
    $pathToGet += "\$($Destination)"
  }

  foreach ($releaseFile in $allReleaseFiles) {

    # Only download files for the current release
    if ($releaseFile.Name.StartsWith($pathToGet)) {
      $targetName = $releaseFile.Name -replace '/', '\\'

      if ($Destination -ne ".") {
        $targetName = "$($Destination)\$($targetName)"
      }

      Get-AzureStorageBobContent -Blob $releaseFile.Name `
                                 -Container $StorageContainer `
                                 -Context $storageContext `
                                 -Destination $targetName | Out-Null
    }
  }
}

Export-ModuleMember -Function Get-DeliveryFilesFromAzure