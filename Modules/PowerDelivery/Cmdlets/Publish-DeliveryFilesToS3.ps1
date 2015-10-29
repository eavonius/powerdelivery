<#
.Synopsis
Uploads files for a powerdelivery release to AWS Simple Storage Service for use by nodes that will host the product.

.Description
Uploads files for a powerdelivery release to AWS Simple Storage Service for use by nodes that will host the product. 
All files that are uploaded are prefixed with a path that contains the name of the powerdelivery project and a 
timestamp of the date and time that the target started.

.Example
Delivery:Role {
  param($target, $config, $node)
  
  # Recursively uploads files within the folder "MyApp\bin\Release" 
  # to an AWS S3 bucket below a <ProjectName>\<StartedAt> path.
  Publish-DeliveryFilesToS3 -Path "MyApp\bin\Debug" `
                            -Destination "MyApp" `
                            -ProfileName "MyProfile" `
                            -BucketName "MyAppReleases" `
                            -Recurse
}

.Parameter Path
The path of files to upload relative to the directory above your powerdelivery project.

.Parameter Destination
The directory in which to place uploaded files.

.Parameter ProfileName
The name of the AWS profile containing credentials to use. 
See https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html

.Parameter BucketName
The name of the S3 bucket to publish the release to.

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

.Parameter ProfilesLocation
The location to look in for the AWS profile containing credentials.
See https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html
#>
function Publish-DeliveryFilesToS3 {
  param(
    [Parameter(Position=0,Mandatory=1)][string] $Path,
    [Parameter(Position=1,Mandatory=1)][string] $Destination,
    [Parameter(Position=2,Mandatory=1)][string] $ProfileName,
    [Parameter(Position=3,Mandatory=1)][string] $BucketName,
    [Parameter(Position=4,Mandatory=0)][string] $Filter,
    [Parameter(Position=5,Mandatory=0)][string[]] $Include,
    [Parameter(Position=6,Mandatory=0)][string[]] $Exclude,
    [Parameter(Position=7,Mandatory=0)][switch] $Recurse,
    [Parameter(Position=8,Mandatory=0)][int] $Keep = 5,
    [Parameter(Position=9,Mandatory=0)][string] $ProfilesLocation
  )

  $verbose = Test-Verbose

  if (-not ("win32.Shell" -as [type])) {
      Add-Type -Namespace win32 -Name Shell -MemberDefinition @"
      [DllImport("Shlwapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern bool PathRelativePathTo(System.Text.StringBuilder lpszDst,
      string From, System.IO.FileAttributes attrFrom, String to, System.IO.FileAttributes attrTo);
"@
  }

  Import-Module AWSPowerShell

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

    # Upload to S3
    Set-Location $tempGuidDir
    foreach ($file in (Get-ChildItem . -Recurse -File)) {

      $relativePath = New-Object -TypeName System.Text.StringBuilder 260
      [win32.Shell]::PathRelativePathTo($relativePath, $tempProjectDir, [System.IO.FileAttributes]::Normal, $file.FullName, [System.IO.FileAttributes]::Normal) | Out-Null

      Write-S3Object -BucketName $BucketName `
                     -Key $relativePath.ToString() `
                     -File $file.FullName | Out-Null
    }

    # Get all release files
    $allReleaseFiles = Get-S3Object -BucketName $BucketName `
                                    -KeyPrefix $target.ProjectName

    $releases = @()

    # Iterate release files to find releases
    foreach ($releaseFile in $allReleaseFiles) {
      $pathSegments = $releaseFile.Key -split '/'
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

          # Check whether s3 object key starts with release prefix
          if ($releaseFile.Key.StartsWith($releasePrefix)) {

            # Delete the S3 object
            Remove-S3Object -BucketName $BucketName `
                            -Key $releaseFile.Key `
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

Export-ModuleMember -Function Publish-DeliveryFilesToS3