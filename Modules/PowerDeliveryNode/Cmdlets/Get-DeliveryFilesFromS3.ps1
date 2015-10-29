<#
.Synopsis
Downloads files that were published by powerdelivery to an AWS Simple Storage Service bucket 
during the current run of a target onto a node.

.Description
Downloads files that were published by powerdelivery to an AWS Simple Storage Service bucket 
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
  
  # Downloads files within the folder "MyApp" that were uploaded to S3
  # into a local directory for the release on the node created above.
  Get-DeliveryFilesFromS3 -Target $target `
                          -Path "MyApp" `
                          -Destination $releasePath `
                          -ProfileName "MyProfile" `
                          -BucketName "MyAppReleases"
}

.Parameter Target
The $target parameter from the role.

.Parameter Path
The path of files to download relative to the release directory (<ProjectName>/<StartedAt>) 
uploaded to S3 with the Publish-DeliveryFilesToS3 cmdlet.

.Parameter Destination
The directory in which to place downloaded files. The New-DeliveryReleasePath cmdlet 
is recommended to enable rollback via the Undo-DeliveryReleasePath cmdlet in a Down block.

.Parameter ProfileName
The name of the AWS profile containing credentials to use. 
See https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html

.Parameter BucketName
The name of the S3 bucket that contains files uploaded with the Publish-DeliveryFilesToS3 cmdlet in 
a prior role that ran on localhost to create a release.

.Parameter ProfilesLocation
The location to look in for the AWS profile containing credentials.
See https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html
#>
function Get-DeliveryFilesFromS3 {
  param(
    [Parameter(Position=0,Mandatory=1)][hashtable] $Target,
    [Parameter(Position=1,Mandatory=1)][string] $Path,
    [Parameter(Position=2,Mandatory=1)][string] $Destination,
    [Parameter(Position=3,Mandatory=1)][string] $ProfileName,
    [Parameter(Position=4,Mandatory=1)][string] $BucketName,
    [Parameter(Position=5,Mandatory=0)][string] $ProfilesLocation
  )

  $verbose = Test-Verbose

  if (-not ("win32.Shell" -as [type])) {
      Add-Type -Namespace win32 -Name Shell -MemberDefinition @"
      [DllImport("Shlwapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern bool PathRelativePathTo(System.Text.StringBuilder lpszDst,
      string From, System.IO.FileAttributes attrFrom, String to, System.IO.FileAttributes attrTo);
"@
  }

  $setAwsCredentialsArgs = @{
    ProfileName = $ProfileName
  }

  if (![String]::IsNullOrEmpty($ProfilesLocation)) {
    $setAwsCredentialsArgs.Add("ProfilesLocation", $ProfilesLocation)
  }

  # Set the active AWS credentials
  Set-AwsCredentials @$setAwsCredentialsArgs

  if ($verbose) {
    Write-Host "Using AWS profile ""$ProfileName"""
  }

  # Connect to the S3 bucket
  $bucket = Get-S3Bucket $BucketName
  if (!$bucket) {
    throw "S3 bucket $BucketName not found."
  }

  # List all files in the container for all releases
  $allReleaseFiles = Get-S3Object -BucketName $BucketName `
                                  -KeyPrefix $target.ProjectName

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
    if ($releaseFile.Key.StartsWith($pathToGet)) {

      # Fix up the filename to exclude the release and timestamp
      $targetPath = $releaseFile.Key.Substring($releasePrefix.Length + 1)
      $targetPath = $targetPath -replace '/', '\'
      $targetPath = Join-Path $Destination $targetPath

      # Create the directory containing the file if it doesn't exist
      $targetDir = [IO.Path]::GetDirectoryName($targetPath)
      if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory $targetDir | Out-Null
      }

      # Download the file
      Read-S3Object -BucketName $BucketName `
                    -Key $releaseFile.Key `
                    -File $targetPath | Out-Null
    }
  }
}

Export-ModuleMember -Function Get-DeliveryFilesFromS3
