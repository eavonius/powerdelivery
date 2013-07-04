<#
.Synopsis
Gets whether the build is running on the TFS server.

.Description
Returns whether the build is executing on the build server or not.

.Outputs
Whether the build is executing on the build server or not.

.Example
$onServer = Get-BuildOnServer
#>
function Get-BuildOnServer {
    [CmdletBinding()]
    param()
    return $powerdelivery.onServer
}