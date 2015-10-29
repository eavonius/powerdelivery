<#
.Synopsis
Uploads files for a powerdelivery release to Windows Azure for use by nodes that will host the product.

.Description
Uploads files for a powerdelivery release to Windows Azure for use by nodes that will host the product. 
All files that are uploaded are prefixed with a path that contains the name of the powerdelivery project and a 
timestamp of the date and time that the target started.

.Example
Delivery:Role {
  param($target, $config, $node)
  
  # Recursively uploads files within the folder "MyApp\bin\Release" to a Windows Azure 
  # storage container below a <ProjectName>\<StartedAt> path.
  Publish-DeliveryFilesToAzure -Path "MyApp\bin\Debug" `
                               -Destination "MyApp" `
                               -Credential $target.Credentials['admin@myazuredomain.com'] `
                               -SubscriptionId $config.MyAzureSubsciptionId `
                               -StorageAccountName $config.MyAzureStorageAccountName `
                               -StorageAccountKey $config.MyAzureStorageAccountKey `
                               -StorageContainer $config.MyAzureStorageContainer `
                               -Recurse
}

.Parameter Path
The path of files to upload relative to the directory above your powerdelivery project.

.Parameter Destination
The directory in which to place uploaded files.

.Parameter Credential
The Windows Azure account credentials to use.

.Parameter SubscriptionId
A Windows Azure subscription that the account in the Credential parameter is permitted 
to use.

.Parameter StorageAccountName
A Windows Azure storage account that the account in the Credential parameter is permitted 
to access.

.Parameter StorageAccountKey
A Windows Azure storage account key that matches the StorageAccountName parameter providing 
read and write access.

.Parameter StorageContainer
A container within the Windows Azure storage account referred to in the StorageAccountName 
parameter into which to upload files.

.Parameter Filter
A comma-separated list of file extensions to filter for. Others will be excluded.

.Parameter Include
A comma-separated list of paths to include. Others will be excluded.

.Parameter Exclude
A comma-separated list of paths to exclude. Others will be included.

.Parameter Recurse
Uploads files in subdirectories below the directory specified by the Path parameter.

.Parameter Keep
The number of previous releases to keep. Defaults to 5.
#>
function Publish-DeliveryFilesToAzure {
  param(
    [Parameter(Position=0,Mandatory=1)][string] $Path,
    [Parameter(Position=1,Mandatory=1)][string] $Destination,
    [Parameter(Position=2,Mandatory=1)][PSCredential] $Credential,
    [Parameter(Position=3,Mandatory=1)][string] $SubscriptionId,
    [Parameter(Position=4,Mandatory=1)][string] $StorageAccountName,
    [Parameter(Position=5,Mandatory=1)][string] $StorageAccountKey,
    [Parameter(Position=6,Mandatory=1)][string] $StorageContainer,
    [Parameter(Position=7,Mandatory=0)][string] $Filter,
    [Parameter(Position=8,Mandatory=0)][string[]] $Include,
    [Parameter(Position=9,Mandatory=0)][string[]] $Exclude,
    [Parameter(Position=10,Mandatory=0)][switch] $Recurse,
    [Parameter(Position=11,Mandatory=0)][int] $Keep = 5
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

  $appDataDir = [Environment]::GetFolderPath("ApplicationData")
  $tempGuidDir = Join-Path $appDataDir "PowerDelivery\$([System.Guid]::NewGuid())"
  $tempProjectDir = Join-Path $tempGuidDir $target.ProjectName
  $tempReleaseDir = Join-Path $tempProjectDir $target.StartedAt

  New-Item -ItemType Directory $tempReleaseDir | Out-Null

  try {

    # Check if path is directory
    $pathIsDirectory = (Get-Item $Path) -is [System.IO.DirectoryInfo]

    if ($pathIsDirectory) {

      $copyArgs = @{
        Path = $Path;
        Destination = "$tempReleaseDir\$Destination";
        Filter = $Filter;
        Exclude = $Exclude;
        Include = $Include
      }

      if ($Recurse) {
        $copyArgs.Add('Recurse', $Recurse)
      }

      # Copy files to temp dir
      Copy-Item @copyArgs | Out-Null
    }
    else {

      # Copy file to temp dir
      Copy-Item $Path "$tempReleaseDir\$Destination" | Out-Null
    }

    # Upload to azure
    Set-Location $tempGuidDir
    foreach ($file in (Get-ChildItem . -Recurse -File)) {

      $relativePath = New-Object -TypeName System.Text.StringBuilder 260
      [win32.Shell]::PathRelativePathTo($relativePath, $tempProjectDir, [System.IO.FileAttributes]::Normal, $file.FullName, [System.IO.FileAttributes]::Normal) | Out-Null

      Set-AzureStorageBlobContent -File $file.FullName `
                                  -Blob $relativePath.ToString() `
                                  -Container $StorageContainer `
                                  -Context $storageContext | Out-Null
    }

    # Get all release files
    $allReleaseFiles = Get-AzureStorageBlob -Blob "$($target.ProjectName)*" `
                                            -Container $StorageContainer `
                                            -Context $storageContext

    $releases = @()

    # Iterate release files to find releases
    foreach ($releaseFile in $allReleaseFiles) {
      $pathSegments = $releaseFile.Name -split '/'
      $releaseSegment = $pathSegments[1]
      if (!($releases -contains $releaseSegment)) {
        $releases += $releaseSegment
      }
    }

    # If we have releases to delete
    if ($releases.count -gt $Keep) {

      # Determine how many to remove
      $oldReleaseCount = $releases.count - $Keep

      # Get the releases to delete
      $releasesToDelete = $releases | Sort-Object | Select -First $oldReleaseCount

      # Iterate release files
      foreach ($releaseFile in $allReleaseFiles) {
      
        # Iterate releases to delete
        foreach ($releaseToDelete in $releasesToDelete) {

          $releasePrefix = "$($target.ProjectName)/$releaseToDelete"

          # Check whether blob name starts with release prefix
          if ($releaseFile.Name.StartsWith($releasePrefix)) {

            # Delete the blob
            Remove-AzureStorageBlob -Blob $releaseFile.Name `
                                    -Container $StorageContainer `
                                    -Context $storageContext `
                                    -Force | Out-Null
          }
        }
      }
    }
  }
  finally {
    Set-Location $target.StartDir

    # Cleanup
    Remove-Item $tempGuidDir -Recurse -Force
  }
}

Export-ModuleMember -Function Publish-DeliveryFilesToAzure