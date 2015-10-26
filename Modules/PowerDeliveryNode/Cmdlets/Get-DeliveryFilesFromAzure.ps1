<#
.Synopsis
Downloads files that were published by powerdelivery to Windows Azure 
during the current run of a target onto a node.

.Description
Downloads files that were published by powerdelivery to Windows Azure 
during the current run of a target onto a node.

.Example
Delivery:Role {
  param($target, $config, $node)

  # You must install PowerDeliveryNode using chocolatey in a 
  # role that has run before this one on the remote node first.
  Import-Module PowerDeliveryNode

  # $releasePath will be C:\Users\<User>\AppData\Roaming\<Project>\Current 
  # pointing to a yyyyMMdd_HHmmss folder in the same directory.
  $releasePath = New-DeliveryReleasePath $target [Environment]::GetFolderPath("AppData")
  
  # Downloads files within the folder "MyApp" that were uploaded to Azure
  # into a local directory for the release on the node created above.
  Get-DeliveryFilesFromAzure -Target $target `
                             -Path "MyApp" `
                             -Destination $releasePath `
                             -Credential $target.Credentials['admin@myazuredomain.com'] `
                             -SubscriptionId $config.MyAzureSubsciptionId `
                             -StorageAccountName $config.MyAzureStorageAccountName `
                             -StorageAccountKey $config.MyAzureStorageAccountKey `
                             -StorageContainer $config.MyAzureStorageContainer
}

.Parameter Target
The $target parameter from the role.

.Parameter Path
The path of files to download relative to the release directory (<ProjectName>/<StartedAt>) 
uploaded to Azure with the Publish-DeliveryFilesToAzure cmdlet.

.Parameter Destination
The directory in which to place downloaded files. The New-DeliveryReleasePath cmdlet 
is recommended to enable rollback via the Undo-DeliveryReleasePath cmdlet in a Down block.

.Parameter Credential
The Windows Azure account credentials to use. You must configure the computer running powerdelivery 
as described at http://www.powerdelivery.io/secrets.html#using_credentials_in_remote_roles 
for these to travel from to the node that will download files with this cmdlet.

.Parameter SubscriptionId
A Windows Azure subscription that the account in the Credential parameter is permitted 
to use.

.Parameter StorageAccountName
A Windows Azure storage account that the account in the Credential parameter is permitted 
to access.

.Parameter StorageAccountKey
A Windows Azure storage account key that matches the StorageAccountName parameter providing 
read access.

.Parameter StorageContainer
A container within the Windows Azure storage account referred to in the StorageAccountName 
parameter that contains files uploaded with the Publish-DeliveryFilesToAzure cmdlet in 
a prior role that ran on localhost to create a release.
#>
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

  # List all files in the container for all releases
  $allReleaseFiles = Get-AzureStorageBlob -Blob "$($target.ProjectName)*" `
                                          -Container $StorageContainer `
                                          -Context $storageContext

  $releasePrefix = "$($target.ProjectName)/$($target.StartedAt)"
  $pathToGet = $releasePrefix

  # Append the source path if not the entire directory
  if ($Path -ne ".") {
    $extraPath = $Path -replace '\\', '/'

    if ($extraPath.StartsWith("/")) {
      $extraPath = $extraPath.Substring(1)
    }

    $pathToGet = "$releasePrefix/$extraPath"
  }

  # Iterate the files in the release
  foreach ($releaseFile in $allReleaseFiles) {

    # Only download files for the current release
    if ($releaseFile.Name.StartsWith($pathToGet)) {

      # Fix up the filename to exclude the release and timestamp
      $targetPath = $releaseFile.Name.Substring($releasePrefix.Length + 1)
      $targetPath = $targetPath -replace '/', '\'
      $targetPath = Join-Path $Destination $targetPath

      # Create the directory containing the file if it doesn't exist
      $targetDir = [IO.Path]::GetDirectoryName($targetPath)
      if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory $targetDir | Out-Null
      }

      # Download the file
      Get-AzureStorageBlobContent -Blob $releaseFile.Name `
                                  -Container $StorageContainer `
                                  -Context $storageContext `
                                  -Destination $targetPath | Out-Null
    }
  }
}

Export-ModuleMember -Function Get-DeliveryFilesFromAzure
