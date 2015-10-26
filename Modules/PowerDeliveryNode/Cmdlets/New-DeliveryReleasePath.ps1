<#
.Synopsis
Creates a new release directory on a remote node being deployed to with powerdelivery.

.Description
Creates a new release directory on a remote node being deployed to with powerdelivery. 
A directory will be created within the path you specify and named after the ProjectName 
property of the target. A directory will be created within it with the timestamp of the 
current run of the target and symbolicly linked to "Current".

Any releases older than the number in the Keep parameter will be deleted.

.Example
Delivery:Role -Up {
  param($target, $config, $node)

  # You must install PowerDeliveryNode using chocolatey in a 
  # role that has run before this one on the remote node first.
  Import-Module PowerDeliveryNode

  # $releasePath will be C:\Users\<User>\AppData\Roaming\<Project>\Current 
  # pointing to a yyyyMMdd_HHmmss folder in the same directory.
  $releasePath = New-DeliveryReleasePath $target [Environment]::GetFolderPath("AppData")
} -Down {

  # You must install PowerDeliveryNode using chocolatey in a 
  # role that has run before this one on the remote node first.
  Import-Module PowerDeliveryNode
  
  # This will rollback a previous release. If no previous 
  # release exists it will be the same path as current.
  $releasePath = Undo-DeliveryReleasePath $target [Environment]::GetFolderPath("AppData")
}

The release will be created at the path:

C:\Users\<User>\AppData\Roaming\<Project>\<StartedAt>

And symlinked to:

C:\Users\<User>\AppData\Roaming\<Project>\Current

.Parameter Target
The hash of target properties for the powerdelivery run.

.Parameter Path
The parent path into which to create the release path.

.Parameter Keep
The number of previous releases to keep. Defaults to 5.
#>
function New-DeliveryReleasePath {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][hashtable] $Target,
    [Parameter(Position=1,Mandatory=1)][string] $Path,
    [Parameter(Position=2,Mandatory=0)][int] $Keep = 5
  )

  # Reference a sub-directory named after the project
  $projectPath = Join-Path $Path $target.ProjectName

  # Create a directory for this release
  $currentReleasePath = Join-Path $projectPath "Current"
  $thisReleasePath = Join-Path $projectPath $target.StartedAt

  if (!(Test-Path $thisReleasePath)) {
    New-Item $thisReleasePath -ItemType Directory | Out-Null

    # Remove old link to current release
    if (Test-Path $currentReleasePath) {
      & cmd /c "rmdir ""$currentReleasePath"""
    }

    # Link this release to the current release
    & cmd /c "mklink /J ""$currentReleasePath"" ""$thisReleasePath""" | Out-Null

    # Get releases
    $releases = Get-ChildItem -Directory $projectPath -Exclude "Current"

    # Delete releases older than the last 5
    if ($releases.count -gt $Keep) {
      $oldReleaseCount = $releases.count - $Keep
      $releases | 
        Sort-Object -Property Name | 
          Select -First $oldReleaseCount | 
            Remove-Item -Force -Recurse | Out-Null
    }
  }

  $currentReleasePath
}

Export-ModuleMember -Function New-DeliveryReleasePath
