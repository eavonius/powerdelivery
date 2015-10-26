<#
.Synopsis
Rolls back to a previous release directory on a remote node being deployed to with powerdelivery.

.Description
Rolls back to a previous release directory on a remote node being deployed to with powerdelivery.
Modifies the symbolic link pointing to the current release path to point to the previous release 
and deletes the old current release directory. If no previous release exists, will leave the 
current release as is and return it.

.Example
Delivery:Role -Up {
  param($target, $config, $node)

  # You must install PowerDeliveryNode using chocolatey in a 
  # role that has run before this one on the remote node first.
  Import-Module PowerDeliveryNode

  # $releasePath will be C:\Users\<User>\AppData\Roaming\<Project>\Current
  $releasePath = New-DeliveryReleasePath $target [Environment]::GetFolderPath("AppData")
} -Down {

  # You must install PowerDeliveryNode using chocolatey in a 
  # role that has run before this one on the remote node first.
  Import-Module PowerDeliveryNode
  
  # This will rollback a previous release. If no previous 
  # release exists it will be the same path as current.
  $releasePath = Undo-DeliveryReleasePath $target [Environment]::GetFolderPath("AppData")
}

The releases will be looked for in the path:

C:\Users\<User>\AppData\Roaming\<Project>

And the previous release symlinked to:

C:\Users\<User>\AppData\Roaming\<Project>\Current

.Parameter Target
The hash of target properties for the powerdelivery run.

.Parameter Path
The parent path in which to look for releases.
#>
function Undo-DeliveryReleasePath {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][hashtable] $Target,
    [Parameter(Position=1,Mandatory=1)][string] $Path
  )

  $previousReleasePath = $null

  # Reference a sub-directory named after the project
  $projectPath = Join-Path $Path $target.ProjectName

  # If at least one release has occurred
  if (Test-Path $projectPath) {

    # Get current and previous release
    $lastRelease = Get-ChildItem -Directory $projectPath -Exclude "Current" | 
      Sort-Object -Descending -Property Name | Select -First 2

    # Only rollback if we've got a previous release
    if ($lastRelease.count -eq 2) {

      $previousReleasePath = $lastRelease[1]

      # Remove link to current release
      $currentReleasePath = Join-Path $projectPath "Current"
      if (Test-Path $currentReleasePath) {
        & cmd /c "rmdir ""$currentReleasePath"""
      }

      # Link current to previous release
      & cmd /c "mklink /J ""$currentReleasePath"" ""$previousReleasePath""" | Out-Null

      # Delete old current release
      Remove-Item -Force -Recurse $lastRelease[0] | Out-Null
    }
    elseif ($lastRelease.count -eq 1) {

      # Return current if no previous release
      $previousReleasePath = Join-Path $projectPath "Current"
    }
  }

  $previousReleasePath
}

Export-ModuleMember -Function Undo-DeliveryReleasePath
