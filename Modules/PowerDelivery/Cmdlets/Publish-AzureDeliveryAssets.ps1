function Publish-AzureDeliveryFiles {
  param(
    [Parameter(Position=0,Mandatory=1)][string] $Path,
    [Parameter(Position=1,Mandatory=1)][string] $Destination,
    [Parameter(Position=2,Mandatory=1)] $Credential,
    [Parameter(Position=3,Mandatory=1)][string] $SubscriptionId,
    [Parameter(Position=4,Mandatory=1)][string] $StorageAccountName,
    [Parameter(Position=5,Mandatory=1)][string] $StorageAccountKey,
    [Parameter(Position=6,Mandatory=1)][string] $StorageContainer,
    [Parameter(Position=7,Mandatory=0)][string] $Filter,
    [Parameter(Position=8,Mandatory=0)][string[]] $Include,
    [Parameter(Position=9,Mandatory=0)][string[]] $Exclude,
    [Parameter(Position=10,Mandatory=0)][switch] $Recurse
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

  <#
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
  }
  finally {
    Set-Location $target.StartDir
    Remove-Item $tempGuidDir -Recurse -Force
  }
  #>
}

Export-ModuleMember -Function Publish-AzureDeliveryFiles