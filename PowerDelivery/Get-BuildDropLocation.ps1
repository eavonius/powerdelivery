<#
.Synopsis
Gets the remote UNC path into which build assets should be placed.

.Description
Gets the remote UNC path into which build assets should be placed. You can use the 
Publish-BuildAssets and Get-BuildAssets functions to push and pull files between 
the local directory and the one returned by calling this function.

.Outputs
The remote UNC path into which build assets should be placed.

.Example
$dropLocation = Get-BuildDropLocation
#>
function Get-BuildDropLocation {
    [CmdletBinding()]
    param()
    return $powerdelivery.dropLocation
}