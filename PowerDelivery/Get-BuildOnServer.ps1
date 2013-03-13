<#
.Description
Returns whether the build is executing on the build server or not.

.Outputs
string - Whether the build is executing on the build server or not.

.Example
$script:buildOnServer = Get-BuildOnServer
#>
function Get-BuildOnServer {
    [CmdletBinding()]
    param()
    return $powerdelivery.onServer
}